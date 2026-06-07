import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const HF_BASE_URL = "https://huggingface.co";
const EMBEDDING_MODEL = "intfloat/multilingual-e5-large";

const BATCH_SIZE = 10; // entradas por lote
const DELAY_MS = 500; // pausa entre lotes para no saturar HF

interface JournalEntry {
  id: string;
  title: string;
  content_v2: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response(null, { headers: corsHeaders() });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const HF_API_KEY = Deno.env.get("HF_API_KEY");
  if (!HF_API_KEY) return json({ error: "Configuración incompleta" }, 500);

  // user_id opcional — si no se pasa, procesa TODOS los usuarios (admin use)
  let userId: string | null = null;
  let maxItems: number = 100;

  try {
    const body = await req.json().catch(() => ({}));
    userId = body?.user_id ?? null;
    maxItems = body?.max_items ?? 100;
  } catch {
    // body vacío está bien
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // ── Leer entradas sin embedding ──────────────────────────────
  let query = supabase
    .from("journal_entries")
    .select("id, title, content_v2")
    .is("embedding", null)
    .order("created_at", { ascending: true })
    .limit(maxItems);

  if (userId) query = query.eq("user_id", userId);

  const { data: entries, error: dbError } = await query;

  if (dbError) {
    console.error("[backfill] db error:", dbError.message);
    return json({ error: "Error leyendo entradas" }, 500);
  }

  if (!entries || entries.length === 0) {
    return json({
      processed: 0,
      failed: 0,
      message: "No hay entradas pendientes",
    });
  }

  console.log(`[backfill] processing ${entries.length} entries`);

  // ── Procesar en lotes ────────────────────────────────────────
  let processed = 0;
  let failed = 0;

  for (let i = 0; i < entries.length; i += BATCH_SIZE) {
    const batch = (entries as JournalEntry[]).slice(i, i + BATCH_SIZE);

    await Promise.allSettled(
      batch.map(async (entry) => {
        try {
          const text =
            `passage: ${entry.title ?? ""}\n${(entry.content_v2 ?? "").slice(0, 500)}`.trim();
          const embedding = await fetchEmbedding(text, HF_API_KEY);

          const { error: updateError } = await supabase
            .from("journal_entries")
            .update({ embedding: embedding })
            .eq("id", entry.id);

          if (updateError) throw new Error(updateError.message);

          processed++;
          console.log(`[backfill] ✓ ${entry.id}`);
        } catch (e) {
          failed++;
          console.error(`[backfill] ✗ ${entry.id}:`, e);
        }
      }),
    );

    // Pausa entre lotes excepto en el último
    if (i + BATCH_SIZE < entries.length) {
      await delay(DELAY_MS);
    }
  }

  console.log(`[backfill] done — processed: ${processed}, failed: ${failed}`);
  return json({
    processed,
    failed,
    total: entries.length,
    message: `Backfill completado: ${processed}/${entries.length}`,
  });
});

// ── Helpers ──────────────────────────────────────────────────────

// 2. Función fetchEmbedding corregida y adaptada
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

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
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
