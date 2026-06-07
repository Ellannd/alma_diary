import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const HF_BASE_URL = "https://router.huggingface.co/v1";
const EMBEDDING_MODEL = "intfloat/multilingual-e5-large";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response(null, { headers: corsHeaders() });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const HF_API_KEY = Deno.env.get("HF_API_KEY");
  if (!HF_API_KEY) return json({ error: "Configuración incompleta" }, 500);

  let entryId: string;
  let userId: string;
  let plainText: string | undefined;

  try {
    const body = await req.json();
    entryId = body?.entry_id;
    userId = body?.user_id;
    plainText = body?.plain_text as string | undefined;
    if (!entryId || !userId)
      return json({ error: "entry_id y user_id requeridos" }, 400);
  } catch {
    return json({ error: "Body inválido" }, 400);
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // ── Leer la entrada ──────────────────────────────────────────
  const { data: entry, error: dbError } = await supabase
    .from("journal_entries")
    .select("title, content_v2")
    .eq("id", entryId)
    .eq("user_id", userId)
    .single();

  if (dbError || !entry) {
    return json({ error: "Entrada no encontrada" }, 404);
  }

  // ── Construir texto a embeddar ───────────────────────────────

  const text = plainText
    ? `passage: ${plainText.slice(0, 500)}`
    : `passage: ${entry.title ?? ""}\n${(entry.content_v2 ?? "").slice(0, 400)}`;

  // ── Llamar a HF ──────────────────────────────────────────────
  let embedding: number[];

  try {
    embedding = await fetchEmbedding(text, HF_API_KEY);
  } catch (e) {
    console.error("[generate-embedding] HF error:", e);
    return json({ error: "Error generando embedding" }, 502);
  }

  // ── Guardar en Supabase ──────────────────────────────────────
  const { error: updateError } = await supabase
    .from("journal_entries")
    .update({ embedding: JSON.stringify(embedding) })
    .eq("id", entryId)
    .eq("user_id", userId);

  if (updateError) {
    console.error("[generate-embedding] update error:", updateError.message);
    return json({ error: "Error guardando embedding" }, 500);
  }

  console.log(`[generate-embedding] saved for entry: ${entryId}`);
  return json({ success: true });
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
