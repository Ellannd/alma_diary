// supabase/functions/generate-psych-profile/index.ts

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RACE_MODELS = [
  "openai/gpt-oss-120b:groq",
  "Qwen/Qwen3-8B:nscale",
  "meta-llama/Llama-3.1-8B-Instruct:novita",
  "Qwen/Qwen2.5-7B-Instruct:together",
];

const FALLBACK_MODELS = [
  "meta-llama/Llama-3.2-3B-Instruct:featherless-ai",
  "google/gemma-3-1b-it:featherless-ai",
];

const HF_BASE_URL = "https://router.huggingface.co/v1/chat/completions";

interface JournalEntry {
  title: string;
  content_v2: string;
  created_at: string;
  sentiment?: string;
  sentiment_score?: number;
  archetype?: string;
}

interface PsychProfile {
  attachment_style: string;
  core_wounds: string[];
  emotional_patterns: string[];
  current_focus: string[];
  communication_style: string;
  dominant_emotions: string[];
  psychological_needs: string[];
  coping_strategies: string[];
  growth_areas: string[];
  narrative_summary: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response(null, { headers: corsHeaders() });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const HF_API_KEY = Deno.env.get("HF_API_KEY");
  if (!HF_API_KEY) return json({ error: "Configuración incompleta" }, 500);

  let userId: string;

  try {
    const body = await req.json();
    userId = body?.user_id;
    if (!userId) return json({ error: "user_id requerido" }, 400);
  } catch {
    return json({ error: "Body inválido" }, 400);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // ── Cargar últimas 20 entradas para el análisis ──────────────
  const { data: entries, error: dbError } = await supabase
    .from("journal_entries")
    .select(
      "title, content_v2, created_at, sentiment, sentiment_score, archetype",
    )
    .eq("user_id", userId)
    .order("created_at", { ascending: false })
    .limit(20);

  if (dbError) {
    console.error("[psych-profile] db error:", dbError.message);
    return json({ error: "Error leyendo entradas" }, 500);
  }

  if (!entries || entries.length < 3) {
    return json({ error: "Entradas insuficientes (mínimo 3)" }, 400);
  }

  // ── Contar total de entradas para metadata ───────────────────
  const { count: totalCount } = await supabase
    .from("journal_entries")
    .select("*", { count: "exact", head: true })
    .eq("user_id", userId);

  // ── Construir prompt de análisis ─────────────────────────────
  const entriesText = (entries as JournalEntry[])
    .map((e, i) => {
      const date = new Date(e.created_at).toLocaleDateString("es-ES");
      const sentiment = e.sentiment
        ? ` [${e.sentiment}${e.sentiment_score != null ? ` ${(e.sentiment_score * 100).toFixed(0)}%` : ""}]`
        : "";
      const archetype = e.archetype ? ` [${e.archetype}]` : "";
      return `[${i + 1}] ${date}${sentiment}${archetype}\n${(e.content_v2 ?? "").slice(0, 400)}`;
    })
    .join("\n\n---\n\n");

  const systemPrompt = `Eres un psicólogo clínico experto en análisis narrativo y psicología profunda.
Analiza las entradas de diario del usuario y genera un perfil psicológico estructurado.
Sé empático, preciso y no hagas diagnósticos clínicos — describe patrones observados.
Responde SOLO con un objeto JSON válido, sin explicación ni texto adicional.`;

  const userPrompt = `Analiza estas entradas de diario y genera un perfil psicológico:

${entriesText}

Devuelve EXACTAMENTE este JSON (todos los campos son obligatorios):
{
  "attachment_style": "uno de: secure | anxious | avoidant | disorganized",
  "core_wounds": ["máximo 4 heridas centrales observadas"],
  "emotional_patterns": ["máximo 5 patrones emocionales recurrentes"],
  "current_focus": ["máximo 4 temas actuales dominantes en su vida"],
  "communication_style": "uno de: reflexivo | impulsivo | analítico | emocional | mixto",
  "dominant_emotions": ["máximo 5 emociones más frecuentes"],
  "psychological_needs": ["máximo 4 necesidades psicológicas no cubiertas"],
  "coping_strategies": ["máximo 4 estrategias de afrontamiento observadas"],
  "growth_areas": ["máximo 4 áreas de crecimiento identificadas"],
  "narrative_summary": "párrafo de 2-3 frases describiendo al usuario con calidez y profundidad, en segunda persona"
}`;

  const messages = [
    { role: "system", content: systemPrompt },
    { role: "user", content: userPrompt },
  ];

  // ── Race entre modelos ───────────────────────────────────────
  const controller = new AbortController();
  let profile: PsychProfile | null = null;

  try {
    const winner = await Promise.any(
      RACE_MODELS.map((model) =>
        fetchProfile(model, messages, HF_API_KEY, controller.signal),
      ),
    );
    controller.abort();
    profile = winner.profile;
    console.log(`[psych-profile] winner: ${winner.model}`);
  } catch {
    console.warn("[psych-profile] race failed, trying fallback");
    for (const model of FALLBACK_MODELS) {
      try {
        const result = await fetchProfile(
          model,
          messages,
          HF_API_KEY,
          new AbortController().signal,
        );
        profile = result.profile;
        console.log(`[psych-profile] fallback winner: ${model}`);
        break;
      } catch (e) {
        console.warn(`[psych-profile] fallback ${model} failed: ${e}`);
      }
    }
  }

  if (!profile) return json({ error: "All models failed" }, 502);

  // ── Upsert del perfil en Supabase ────────────────────────────
  const { error: upsertError } = await supabase
    .from("psychological_profiles")
    .upsert(
      {
        user_id: userId,
        attachment_style: profile.attachment_style,
        core_wounds: profile.core_wounds,
        emotional_patterns: profile.emotional_patterns,
        current_focus: profile.current_focus,
        communication_style: profile.communication_style,
        dominant_emotions: profile.dominant_emotions,
        psychological_needs: profile.psychological_needs,
        coping_strategies: profile.coping_strategies,
        growth_areas: profile.growth_areas,
        narrative_summary: profile.narrative_summary,
        entry_count_at_update: totalCount ?? entries.length,
        last_updated: new Date().toISOString(),
      },
      { onConflict: "user_id" },
    );

  if (upsertError) {
    console.error("[psych-profile] upsert error:", upsertError.message);
    return json({ error: "Error guardando perfil" }, 500);
  }

  console.log(`[psych-profile] profile saved for user: ${userId}`);
  return json({ profile });
});

// ── Helpers ──────────────────────────────────────────────────────

async function fetchProfile(
  model: string,
  messages: object[],
  apiKey: string,
  signal: AbortSignal,
) {
  const combined = AbortSignal.any([signal, AbortSignal.timeout(25_000)]);

  const res = await fetch(HF_BASE_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.3, // bajo para consistencia
      max_tokens: 800, // perfil completo necesita más tokens
    }),
    signal: combined,
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`HTTP ${res.status}: ${body.slice(0, 100)}`);
  }

  const data = await res.json();
  const rawText = (data?.choices?.[0]?.message?.content ?? "").trim();
  if (!rawText) throw new Error("Empty response");

  // Extraer JSON limpiando posibles bloques de código
  const match = rawText.match(/\{[\s\S]*\}/);
  if (!match) throw new Error("No JSON found in response");

  const profile = JSON.parse(match[0]) as PsychProfile;

  // Validar campos obligatorios
  const required = [
    "attachment_style",
    "core_wounds",
    "emotional_patterns",
    "current_focus",
    "communication_style",
    "dominant_emotions",
    "psychological_needs",
    "coping_strategies",
    "growth_areas",
    "narrative_summary",
  ];
  for (const field of required) {
    if (!(field in profile)) throw new Error(`Missing field: ${field}`);
  }

  return { profile, model };
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
