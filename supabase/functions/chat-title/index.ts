// supabase/functions/chat-title/index.ts

const RACE_MODELS = [
  "Qwen/Qwen3-8B:nscale",
  "meta-llama/Llama-3.1-8B-Instruct:novita",
  "openai/gpt-oss-120b:groq",
];

const HF_BASE_URL = "https://router.huggingface.co/v1/chat/completions";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response(null, { headers: corsHeaders() });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const HF_API_KEY = Deno.env.get("HF_API_KEY");
  if (!HF_API_KEY) return json({ error: "Configuración incompleta" }, 500);

  let firstMessage: string;

  try {
    const body = await req.json();
    firstMessage = body?.message?.trim();
    if (!firstMessage) return json({ error: "message requerido" }, 400);
    if (firstMessage.length > 500) firstMessage = firstMessage.slice(0, 500);
  } catch {
    return json({ error: "Body inválido" }, 400);
  }

  const messages = [
    {
      role: "system",
      content: `Genera un título corto (máximo 8 palabras) para una conversación que empieza con el mensaje del usuario.
Devuelve SOLO el título, sin comillas, sin puntuación al final, sin explicación.
Ejemplos: "Miedo al futuro", "Un día difícil", "Reflexión sobre trabajo"`,
    },
    {
      role: "user",
      content: firstMessage,
    },
  ];

  const controller = new AbortController();

  try {
    const winner = await Promise.any(
      RACE_MODELS.map((model) =>
        fetchTitle(model, messages, HF_API_KEY, controller.signal),
      ),
    );
    controller.abort();
    return json({ title: winner.title });
  } catch {
    // Fallback: título por fecha si todos fallan
    const fallback = new Date().toLocaleDateString("es-ES", {
      day: "numeric",
      month: "long",
    });
    return json({ title: fallback });
  }
});

async function fetchTitle(
  model: string,
  messages: object[],
  apiKey: string,
  signal: AbortSignal,
) {
  const combined = AbortSignal.any([signal, AbortSignal.timeout(8_000)]);

  const res = await fetch(HF_BASE_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.4,
      max_tokens: 20, // título corto, no necesita más
    }),
    signal: combined,
  });

  if (!res.ok) throw new Error(`HTTP ${res.status}`);

  const data = await res.json();
  const raw = (data?.choices?.[0]?.message?.content ?? "").trim();
  if (!raw) throw new Error("Empty response");

  // Limpiar comillas o puntuación residual
  const title = raw
    .replace(/^["'«»]|["'«»]$/g, "")
    .replace(/[.!?]$/, "")
    .trim();
  if (!title) throw new Error("Empty title after cleanup");

  return { title, model };
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
