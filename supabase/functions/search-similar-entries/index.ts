import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const HF_BASE_URL = "https://router.huggingface.co/v1";
const EMBEDDING_MODEL = "intfloat/multilingual-e5-large";

interface SimilarEntry {
  id: string;
  title: string;
  content_v2: string;
  created_at: string;
  sentiment: string | null;
  archetype: string | null;
  similarity: number;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response(null, { headers: corsHeaders() });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const HF_API_KEY = Deno.env.get("HF_API_KEY");
  if (!HF_API_KEY) return json({ error: "Configuración incompleta" }, 500);

  let userId: string;
  let query: string;
  let matchCount: number;
  let threshold: number;

  try {
    const body = await req.json();
    userId = body?.user_id;
    query = body?.query;
    matchCount = body?.match_count ?? 5;
    threshold = body?.threshold ?? 0.75;

    if (!userId || !query)
      return json({ error: "user_id y query requeridos" }, 400);
  } catch {
    return json({ error: "Body inválido" }, 400);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // ── Embeddar la query ────────────────────────────────────────
  // multilingual-e5 usa prefijo "query: " para búsquedas
  const queryText = `query: ${query}`;

  let embedding: number[];

  try {
    embedding = await fetchEmbedding(queryText, HF_API_KEY);
  } catch (e) {
    console.error("[search-similar] HF error:", e);
    return json({ error: "Error generando embedding" }, 502);
  }

  // ── Buscar entradas similares ────────────────────────────────
  const { data: entries, error: rpcError } = await supabase.rpc(
    "match_journal_entries",
    {
      p_user_id: userId,
      p_embedding: JSON.stringify(embedding),
      p_match_count: matchCount,
      p_threshold: threshold,
    },
  );

  if (rpcError) {
    console.error("[search-similar] rpc error:", rpcError.message);
    return json({ error: "Error en búsqueda" }, 500);
  }

  console.log(
    `[search-similar] found ${entries?.length ?? 0} entries for user: ${userId}`,
  );
  return json({ entries: entries as SimilarEntry[] });
});

// ── Helpers ──────────────────────────────────────────────────────

async function fetchEmbedding(text: string, apiKey: string): Promise<number[]> {
  const res = await fetch(
    "https://router.huggingface.co/together/v1/embeddings",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "intfloat/multilingual-e5-large-instruct",
        input: text,
      }),
      signal: AbortSignal.timeout(20_000),
    },
  );

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`HTTP ${res.status}: ${body.slice(0, 100)}`);
  }

  const data = await res.json();
  const embedding = data?.data?.[0]?.embedding;
  if (!Array.isArray(embedding)) throw new Error("Embedding inválido");

  return embedding;
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
