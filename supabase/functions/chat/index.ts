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

interface ChatMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

interface DiaryEntry {
  title: string;
  content_v2: string;
  created_at: string;
  sentiment?: string;
  sentiment_score?: number;
  archetype?: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response(null, { headers: corsHeaders() });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const HF_API_KEY = Deno.env.get("HF_API_KEY");
  if (!HF_API_KEY) return json({ error: "Configuración incompleta" }, 500);

  let history: ChatMessage[];
  let userId: string;
  let conversationId: string;

  try {
    const body = await req.json();
    history = body?.history ?? [];
    userId = body?.user_id;
    conversationId = body?.conversation_id;

    if (!userId) return json({ error: "user_id requerido" }, 400);
    if (!conversationId)
      return json({ error: "conversation_id requerido" }, 400);
    if (history.length === 0) return json({ error: "history vacío" }, 400);
    if (history.length > 20) history = history.slice(-20);
  } catch {
    return json({ error: "Body inválido" }, 400);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // ── Contexto del diario ──────────────────────────────────────
  const { data: entries, error: dbError } = await supabase
    .from("journal_entries")
    .select(
      "title, content_v2, created_at, sentiment, sentiment_score, archetype",
    )
    .eq("user_id", userId)
    .order("created_at", { ascending: false })
    .limit(5);

  // ── Perfil psicológico ───────────────────────────────────────
  const { data: psychProfile } = await supabase
    .from("psychological_profiles")
    .select(
      "attachment_style, dominant_emotions, psychological_needs, narrative_summary, communication_style",
    )
    .eq("user_id", userId)
    .maybeSingle();

  const profileContext = buildProfileContext(psychProfile);

  if (dbError) console.error("[chat] db error:", dbError.message);
  const diaryContext = buildDiaryContext(entries ?? []);

  // ── Guardar mensaje del usuario ──────────────────────────────
  const lastUserMessage = [...history].reverse().find((m) => m.role === "user");
  if (lastUserMessage) {
    await supabase.from("chat_messages").insert({
      conversation_id: conversationId,
      user_id: userId,
      role: "user",
      content: lastUserMessage.content,
    });
  }

  // ── Entradas similares por semántica ────────────────────────
  const similarContext = await (async () => {
    if (!lastUserMessage) return "";
    try {
      // Últimos 3 mensajes del usuario como query
      const recentUserMessages = history
        .filter((m) => m.role === "user")
        .slice(-3)
        .map((m) => m.content)
        .join(" ");

      const embedding = await getQueryEmbedding(recentUserMessages, HF_API_KEY);
      const { data } = await supabase.rpc("match_journal_entries", {
        p_user_id: userId,
        p_embedding: embedding,
        p_match_count: 3,
        p_threshold: 0.75,
      });
      return buildSimilarContext(data);
    } catch (e) {
      console.warn("[chat] similar entries failed:", e);
      return "";
    }
  })();

  // ── System prompt ────────────────────────────────────────────
  const systemPrompt = [
    "Eres Alma, un asistente empático integrado en una app de diario personal.",
    "Tu rol es acompañar al usuario, ayudarle a reflexionar y responder con calidez.",

    profileContext
      ? `\n## Perfil psicológico del usuario\n${profileContext}`
      : "",

    diaryContext ? `\n## Contexto del diario\n${diaryContext}` : "",

    similarContext
      ? `\n## Entradas del diario relacionadas con este momento\n${similarContext}`
      : "",

    "\n## Instrucciones",
    "- Responde siempre en el idioma del usuario.",
    "- Sé conciso pero cálido. Ajusta la longitud del mensaje acorde a la profundidad del usuario.",
    "- Usa el perfil psicológico para adaptar tu tono y enfoque.",
    "- Si hay entradas relacionadas, puedes referenciarlas con naturalidad: 'recuerdo que en marzo escribiste...'",
    "- No menciones explícitamente el perfil al usuario — úsalo de forma natural.",
    "- No inventes información que no esté en el contexto.",
  ]
    .filter(Boolean)
    .join("\n")
    .trim();

  const messages: ChatMessage[] = [
    { role: "system", content: systemPrompt },
    ...history,
  ];

  // ── Race entre modelos ───────────────────────────────────────
  const controller = new AbortController();
  let winner: { reply: string; model: string } | null = null;

  try {
    winner = await Promise.any(
      RACE_MODELS.map((model) =>
        fetchChat(model, messages, HF_API_KEY, controller.signal),
      ),
    );
    controller.abort();
    console.log(`[chat] winner: ${winner.model}`);
  } catch {
    console.warn("[chat] race failed, trying fallback serial");
    for (const model of FALLBACK_MODELS) {
      try {
        winner = await fetchChat(
          model,
          messages,
          HF_API_KEY,
          new AbortController().signal,
        );
        console.log(`[chat] fallback winner: ${winner.model}`);
        break;
      } catch (e) {
        console.warn(`[chat] fallback ${model} failed: ${e}`);
      }
    }
  }

  if (!winner) return json({ error: "All models failed" }, 502);

  // ── Guardar respuesta del asistente ──────────────────────────
  await supabase.from("chat_messages").insert({
    conversation_id: conversationId,
    user_id: userId,
    role: "assistant",
    content: winner.reply,
    model: winner.model,
  });

  // ── Actualizar updated_at de la conversación ─────────────────
  await supabase
    .from("chat_conversations")
    .update({ updated_at: new Date().toISOString() })
    .eq("id", conversationId);

  return json({ reply: winner.reply, model: winner.model });
});

// ── Helpers ──────────────────────────────────────────────────────

async function fetchChat(
  model: string,
  messages: ChatMessage[],
  apiKey: string,
  signal: AbortSignal,
) {
  const combined = AbortSignal.any([signal, AbortSignal.timeout(12_000)]);

  const res = await fetch(HF_BASE_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.7,
      max_tokens: 4096,
    }),
    signal: combined,
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`HTTP ${res.status}: ${body.slice(0, 100)}`);
  }

  const data = await res.json();
  const reply = (data?.choices?.[0]?.message?.content ?? "").trim();
  if (!reply) throw new Error("Empty response");

  return { reply, model };
}

function buildDiaryContext(entries: DiaryEntry[]): string {
  if (entries.length === 0) return "";
  return entries
    .map((e, i) => {
      const date = new Date(e.created_at).toLocaleDateString("es-ES");
      const sentiment = e.sentiment ? ` · ${e.sentiment}` : "";
      const score =
        e.sentiment_score != null
          ? ` (${(e.sentiment_score * 100).toFixed(0)}%)`
          : "";
      const archetype = e.archetype ? ` · arquetipo: ${e.archetype}` : "";
      const preview = (e.content_v2 ?? "").slice(0, 300);
      return `[${i + 1}] ${date}${sentiment}${score}${archetype}\nTítulo: ${e.title}\n${preview}`;
    })
    .join("\n\n");
}

function buildProfileContext(profile: Record<string, unknown> | null): string {
  if (!profile) return "";

  const lines: string[] = [];

  if (profile.narrative_summary) {
    lines.push(`Resumen: ${profile.narrative_summary}`);
  }
  if (profile.attachment_style) {
    lines.push(`Estilo de apego: ${profile.attachment_style}`);
  }
  if (profile.communication_style) {
    lines.push(`Estilo de comunicación: ${profile.communication_style}`);
  }
  if (
    Array.isArray(profile.dominant_emotions) &&
    profile.dominant_emotions.length
  ) {
    lines.push(`Emociones dominantes: ${profile.dominant_emotions.join(", ")}`);
  }
  if (
    Array.isArray(profile.psychological_needs) &&
    profile.psychological_needs.length
  ) {
    lines.push(
      `Necesidades psicológicas: ${profile.psychological_needs.join(", ")}`,
    );
  }

  return lines.join("\n");
}

async function getQueryEmbedding(
  text: string,
  apiKey: string,
): Promise<string> {
  const res = await fetch("https://router.huggingface.co/v1/embeddings", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "intfloat/multilingual-e5-large",
      input: `query: ${text}`,
    }),
    signal: AbortSignal.timeout(10_000),
  });

  if (!res.ok) throw new Error(`HF embedding failed: ${res.status}`);

  const data = await res.json();
  const embedding = data?.data?.[0]?.embedding;
  if (!Array.isArray(embedding)) throw new Error("Invalid embedding");

  return JSON.stringify(embedding);
}

function buildSimilarContext(
  entries: Array<{
    title: string;
    content_v2: string;
    created_at: string;
    similarity: number;
  }> | null,
): string {
  if (!entries || entries.length === 0) return "";

  return entries
    .map((e) => {
      const date = new Date(e.created_at).toLocaleDateString("es-ES");
      const preview = (e.content_v2 ?? "").slice(0, 300);
      return `[${date}] ${e.title ?? "Sin título"}\n${preview}`;
    })
    .join("\n\n---\n\n");
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
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };
}
