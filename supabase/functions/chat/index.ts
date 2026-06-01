// supabase/functions/chat/index.ts

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RACE_MODELS = [
  "Qwen/Qwen3-8B:nscale",
  "meta-llama/Llama-3.1-8B-Instruct:novita",
  "openai/gpt-oss-120b:groq",
  "Qwen/Qwen2.5-7B-Instruct:together",
];

const FALLBACK_MODELS = [
  "meta-llama/Llama-3.2-3B-Instruct:featherless-ai",
  "google/gemma-3-1b-it:featherless-ai",
];

const HF_BASE_URL = "https://router.huggingface.co/v1/chat/completions";

// ── Tipos ────────────────────────────────────────────────────────
interface ChatMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

interface DiaryEntry {
  content: string;
  created_at: string;
  mood?: string;       // de tu analysis_result si ya lo tienes
}

// ── Handler ──────────────────────────────────────────────────────
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders() });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const HF_API_KEY = Deno.env.get("HF_API_KEY");
  if (!HF_API_KEY) return json({ error: "Configuración incompleta" }, 500);

  let history: ChatMessage[];
  let userId: string;

  try {
    const body = await req.json();
    history = body?.history ?? [];
    userId  = body?.user_id;

    if (!userId) return json({ error: "user_id requerido" }, 400);
    if (history.length === 0) return json({ error: "history vacío" }, 400);

    // Límite de seguridad: últimos 20 mensajes para no reventar el context window
    if (history.length > 20) history = history.slice(-20);
  } catch {
    return json({ error: "Body inválido" }, 400);
  }

  // ── Leer entradas recientes del diario desde Supabase ────────
  // Esto es lo que luego reemplazarás por RAG en v4.0
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: entries } = await supabase
    .from("diary_entries")               // ajusta al nombre real de tu tabla
    .select("content, created_at, mood")
    .eq("user_id", userId)
    .order("created_at", { ascending: false })
    .limit(5);

  const diaryContext = buildDiaryContext(entries ?? []);

  // ── System prompt ────────────────────────────────────────────
  // Diseñado para que el emotion engine solo tenga que añadir
  // un bloque más aquí en v4.0 sin tocar nada más
  const systemPrompt = `
Eres Alma, un asistente empático integrado en una app de diario personal.
Tu rol es acompañar al usuario, ayudarle a reflexionar y responder con calidez.

## Contexto del diario (entradas recientes)
${diaryContext}

## Instrucciones
- Responde siempre en el idioma del usuario.
- Sé conciso pero cálido. Máximo 3 párrafos.
- Si el usuario menciona algo de sus entradas, puedes referenciarlo con naturalidad.
- No inventes información que no esté en el contexto.
- [EMOTION_ENGINE_PLACEHOLDER] <!-- v4.0: aquí irá el tono adaptativo -->
`.trim();

  const messages: ChatMessage[] = [
    { role: "system", content: systemPrompt },
    ...history,
  ];

  // ── Race entre modelos ───────────────────────────────────────
  const controller = new AbortController();

  try {
    const winner = await Promise.any(
      RACE_MODELS.map((model) =>
        fetchChat(model, messages, HF_API_KEY, controller.signal)
      ),
    );
    controller.abort();
    return json({ reply: winner.reply, model: winner.model });

  } catch {
    // Race falló — intentar fallback serial
    for (const model of FALLBACK_MODELS) {
      try {
        const result = await fetchChat(model, messages, HF_API_KEY, controller.signal);
        return json({ reply: result.reply, model: result.model });
      } catch { continue; }
    }
  }

  return json({ error: "All models failed" }, 502);
});

// ── Helpers ──────────────────────────────────────────────────────

async function fetchChat(
  model: string,
  messages: ChatMessage[],
  apiKey: string,
  signal: AbortSignal,
) {
  const timeout  = AbortSignal.timeout(12_000);
  const combined = AbortSignal.any([signal, timeout]);

  const res = await fetch(HF_BASE_URL, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.7,
      max_tokens: 400,
    }),
    signal: combined,
  });

  if (!res.ok) throw new Error(`HTTP ${res.status}`);

  const data  = await res.json();
  const reply = data?.choices?.[0]?.message?.content ?? "";
  if (!reply) throw new Error("Empty response");

  return { reply, model };
}

function buildDiaryContext(entries: DiaryEntry[]): string {
  if (entries.length === 0) return "El usuario aún no tiene entradas en su diario.";

  return entries.map((e, i) => {
    const date = new Date(e.created_at).toLocaleDateString("es-ES");
    const mood = e.mood ? ` [mood: ${e.mood}]` : "";
    return `[${i + 1}] ${date}${mood}\n${e.content.slice(0, 300)}`;
  }).join("\n\n");
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders() },
  });
}

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };
}