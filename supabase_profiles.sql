-- ============================================
-- TABLA DE PERFILES v4 - ONBOARDING COMPLETO
-- ============================================

-- 1. Eliminar tabla anterior y recrear con todos los campos
DROP TABLE IF EXISTS public.profiles CASCADE;

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  is_onboarding_complete BOOLEAN DEFAULT FALSE,
  
  -- Campos de onboarding emocional
  emotional_state TEXT,
  pain_point TEXT,
  hopeful_goal TEXT,
  main_challenge TEXT,
  preferred_language TEXT,
  pain_point_detail TEXT,
  stress_level INTEGER,
  sleep_quality TEXT,
  
  -- Metadatos
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Habilitar Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Política: usuarios solo pueden ver su propio perfil
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

-- Política: usuarios solo pueden actualizar su propio perfil
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Política: usuarios pueden insertar su propio perfil
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================
-- FUNCIÓN Y TRIGGER v4 - MEJORADO PARA OAUTH
-- ============================================

-- Función robusta que maneja datos de Google OAuth y manual
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_full_name TEXT;
  v_avatar_url TEXT;
  v_email TEXT;
BEGIN
  -- Extraer email desde diferentes fuentes
  v_email := COALESCE(
    NEW.email,
    NEW.raw_user_meta_data->>'email',
    NEW.raw_user_meta_data->>'full_name'
  );
  
  -- Extraer full_name desde diferentes fuentes
  v_full_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    COALESCE(NEW.raw_user_meta_data->>'given_name', '') || ' ' || COALESCE(NEW.raw_user_meta_data->>'family_name', ''),
    'Usuario'
  );
  
  -- Limpiar espacios en blanco del nombre
  v_full_name := TRIM(v_full_name);
  IF v_full_name = '' THEN
    v_full_name := 'Usuario';
  END IF;

  -- Extraer avatar_url
  v_avatar_url := COALESCE(
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.raw_user_meta_data->>'picture'
  );

  -- Insertar perfil con todos los campos obligatorios inicializados
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    avatar_url,
    is_onboarding_complete,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    v_email,
    v_full_name,
    v_avatar_url,
    FALSE,  -- onboarding NO completo por defecto
    NOW(),
    NOW()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que ejecuta la función cuando se crea un nuevo usuario
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- ÍNDICES PARA MEJOR RENDIMIENTO
-- ============================================

DROP INDEX IF EXISTS idx_profiles_id;
DROP INDEX IF EXISTS idx_profiles_onboarding;

CREATE INDEX idx_profiles_id ON public.profiles(id);
CREATE INDEX idx_profiles_email ON public.profiles(email) WHERE email IS NOT NULL;
CREATE INDEX idx_profiles_onboarding ON public.profiles(is_onboarding_complete) WHERE is_onboarding_complete = FALSE;

-- ============================================
-- FUNCIÓN PARA ACTUALIZAR ONBOARDING DESDE FLUTTER
-- ============================================

CREATE OR REPLACE FUNCTION public.complete_user_onboarding(
  p_emotional_state TEXT,
  p_pain_point TEXT,
  p_hopeful_goal TEXT,
  p_main_challenge TEXT DEFAULT NULL,
  p_preferred_language TEXT DEFAULT NULL,
  p_pain_point_detail TEXT DEFAULT NULL,
  p_stress_level INTEGER DEFAULT NULL,
  p_sleep_quality TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.profiles
  SET 
    is_onboarding_complete = TRUE,
    emotional_state = p_emotional_state,
    pain_point = p_pain_point,
    hopeful_goal = p_hopeful_goal,
    main_challenge = p_main_challenge,
    preferred_language = p_preferred_language,
    pain_point_detail = p_pain_point_detail,
    stress_level = p_stress_level,
    sleep_quality = p_sleep_quality,
    updated_at = NOW()
  WHERE id = auth.uid();
END;
$$;

-- ============================================
-- JOURNAL ENTRIES - TABLA ÚNICA Y DEFINITIVA
-- ============================================

DROP TABLE IF EXISTS public.journal_entries;

CREATE TABLE IF NOT EXISTS public.journal_entries (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  sentiment TEXT,
  sentiment_score FLOAT,
  archetype TEXT,
  reflection TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "insert own entries" ON public.journal_entries;
CREATE POLICY "insert own entries" ON public.journal_entries
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "select own entries" ON public.journal_entries;
CREATE POLICY "select own entries" ON public.journal_entries
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "update own entries" ON public.journal_entries;
CREATE POLICY "update own entries" ON public.journal_entries
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id);

-- Índices
CREATE INDEX idx_journal_entries_user ON public.journal_entries(user_id);
CREATE INDEX idx_journal_entries_created ON public.journal_entries(created_at DESC);