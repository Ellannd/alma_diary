// Sin ningún import necesario — Supabase lo inyecta automáticamente

const MODELS = [
  "Qwen/Qwen3-8B:nscale",
  "Qwen/Qwen3-1.7B:featherless-ai",
  "meta-llama/Llama-3.1-8B-Instruct:novita",
  "Qwen/Qwen3-32B:groq",
  "mistralai/Mistral-7B-Instruct-v0.2",
    // Modelos grandes (más capaces, más lentos)
  "deepseek-ai/DeepSeek-V4-Pro:novita",
  "deepseek-ai/DeepSeek-V4-Flash:novita",
  "deepseek-ai/DeepSeek-R1:novita",
  "zai-org/GLM-5.1:together",
  "openai/gpt-oss-120b:groq",
  "MiniMaxAI/MiniMax-M2.7:novita",
  "Qwen/Qwen3-Coder-Next:novita",

  // Modelos medianos (balance velocidad/calidad)
  "meta-llama/Llama-3.1-8B-Instruct:novita",
  "meta-llama/Llama-3.1-8B:featherless-ai",
  "Qwen/Qwen3-8B:nscale",
  "Qwen/Qwen2.5-7B-Instruct:together",

  // Modelos pequeños (más rápidos, fallback ligero)
  "meta-llama/Llama-3.2-3B-Instruct:featherless-ai",
  "meta-llama/Llama-3.2-3B:featherless-ai",
  "meta-llama/Llama-3.2-1B-Instruct:novita",
  "meta-llama/Llama-3.2-1B:featherless-ai",
  "google/gemma-3-1b-it:featherless-ai",
];

const HF_BASE_URL = "https://router.huggingface.co/v1/chat/completions";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders() });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  let prompt: string;
  try {
    const body = await req.json();
    prompt = body?.text?.trim();
    if (!prompt || prompt.length < 10) {
      return json({ error: "Texto demasiado corto" }, 400);
    }
    if (prompt.length > 6000) {
      prompt = prompt.slice(0, 6000);
    }
  } catch {
    return json({ error: "Body inválido" }, 400);
  }

  const HF_API_KEY = Deno.env.get("HF_API_KEY");
  if (!HF_API_KEY) {
    console.error("HF_API_KEY secret not set");
    return json({ error: "Configuración del servidor incompleta" }, 500);
  }

  let lastError: string = "Unknown error";

  for (const model of MODELS) {
    try {
      console.log(`[analyze-entry] Trying model: ${model}`);

      const hfRes = await fetch(HF_BASE_URL, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${HF_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model,
          messages: [
            {
              role: "system",
              content: "Return ONLY valid JSON. No <think>. No explanation.",
            },
            { role: "user", content: prompt },
          ],
          temperature: 0.2,
          max_tokens: 300,
        }),
        signal: AbortSignal.timeout(20_000),
      });

      if (!hfRes.ok) {
        const errBody = await hfRes.text();
        console.warn(`[analyze-entry] Model ${model} → HTTP ${hfRes.status}: ${errBody}`);
        lastError = `HF ${hfRes.status}`;
        continue;
      }

      const hfData = await hfRes.json();
      const rawText: string = hfData?.choices?.[0]?.message?.content ?? "";

      if (!rawText) {
        console.warn(`[analyze-entry] Model ${model} → empty content`);
        lastError = "Empty response";
        continue;
      }

      const parsed = extractJsonSafe(rawText);
      if (!parsed) {
        console.warn(`[analyze-entry] Model ${model} → could not parse JSON`);
        lastError = "JSON parse failed";
        continue;
      }

      console.log(`[analyze-entry] Success with model: ${model}`);
      return json({ data: parsed }, 200);

    } catch (e) {
      console.warn(`[analyze-entry] Model ${model} threw: ${e}`);
      lastError = String(e);
      continue;
    }
  }

  console.error(`[analyze-entry] All models failed. Last error: ${lastError}`);
  return json({ error: `All models failed: ${lastError}` }, 502);
});

// ── Helpers ──────────────────────────────────────────────────────

function extractJsonSafe(text: string): Record<string, unknown> | null {
  const match = text.match(/\{[\s\S]*\}/);
  if (!match) return null;
  try {
    return JSON.parse(match[0]);
  } catch {
    return null;
  }
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