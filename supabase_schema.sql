-- ═══════════════════════════════════════════════════════════════════════
-- EcoQuiz — Esquema de Base de Datos para Supabase
-- Ejecutar en: Dashboard → SQL Editor → New query → Pegar → Run
-- ═══════════════════════════════════════════════════════════════════════

-- 1. Perfiles de usuario (extiende auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL DEFAULT 'Explorador',
  role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'teacher')),
  avatar_emoji TEXT DEFAULT '👦🏽',
  hearts INTEGER DEFAULT 5,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Grupos escolares
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL, -- ECO-4A
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Alumnos en grupos (relación muchos a muchos)
CREATE TABLE IF NOT EXISTS group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(group_id, student_id)
);

-- 4. Niveles / Biomas
CREATE TABLE IF NOT EXISTS levels (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  biome TEXT DEFAULT '',
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Preguntas por nivel
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  level_id INTEGER REFERENCES levels(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  image_url TEXT DEFAULT '',
  options JSONB NOT NULL DEFAULT '[]',
  correct_index INTEGER NOT NULL DEFAULT 0,
  hint TEXT DEFAULT '',
  fun_fact TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Progreso del alumno por nivel
CREATE TABLE IF NOT EXISTS student_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  level_id INTEGER REFERENCES levels(id) ON DELETE CASCADE,
  stars_earned INTEGER DEFAULT 0 CHECK (stars_earned BETWEEN 0 AND 3),
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  UNIQUE(student_id, level_id)
);

-- 7. Intentos de quiz (analytics)
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  selected_index INTEGER NOT NULL,
  is_correct BOOLEAN NOT NULL,
  time_seconds INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. Recompensas disponibles
CREATE TABLE IF NOT EXISTS rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  subtitle TEXT DEFAULT '',
  cost INTEGER NOT NULL DEFAULT 10,
  icon_name TEXT DEFAULT 'card_giftcard',
  color_hex TEXT DEFAULT '#F39C12',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 9. Premios comprados
CREATE TABLE IF NOT EXISTS purchased_rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  reward_id UUID REFERENCES rewards(id) ON DELETE CASCADE,
  purchased_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(student_id, reward_id)
);

-- 10. Tarjetas desbloqueadas de la enciclopedia
CREATE TABLE IF NOT EXISTS unlocked_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  card_id INTEGER NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(student_id, card_id)
);

-- ═══════════════════════════════════════════════════════════════════════
-- DATOS INICIALES
-- ═══════════════════════════════════════════════════════════════════════

-- Niveles predeterminados
INSERT INTO levels (id, title, biome, order_index) VALUES
  (0, 'Ciudad', 'ciudad', 0),
  (1, 'Manglar', 'manglar', 1),
  (2, 'Arrecife', 'arrecife', 2),
  (3, 'Bosque', 'bosque', 3),
  (4, 'Selva', 'selva', 4),
  (5, 'Desierto', 'desierto', 5)
ON CONFLICT (id) DO NOTHING;

-- Maestro demo
INSERT INTO profiles (id, name, role) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Profesor Demo', 'teacher')
ON CONFLICT (id) DO NOTHING;

-- Grupo demo
INSERT INTO groups (id, teacher_id, name, code) VALUES
  ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000001', 'Grupo 4A', 'ECO-4A')
ON CONFLICT (id) DO NOTHING;

-- Recompensas demo para el grupo
INSERT INTO rewards (group_id, title, subtitle, cost, icon_name, color_hex) VALUES
  ('00000000-0000-0000-0000-000000000010', 'Avatar Especial', 'Ocelote', 50, 'face', '#8E44AD'),
  ('00000000-0000-0000-0000-000000000010', 'Pista Extra', 'Para el Quiz', 10, 'lightbulb', '#F1C40F'),
  ('00000000-0000-0000-0000-000000000010', 'Fondo Animado', 'Desierto', 100, 'wallpaper', '#27AE60'),
  ('00000000-0000-0000-0000-000000000010', 'Marco de Oro', 'Para tu Perfil', 200, 'crop_square', '#E67E22');

-- ═══════════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (deshabilitado para la demo, habilitar en producción)
-- ═══════════════════════════════════════════════════════════════════════
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchased_rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE unlocked_cards ENABLE ROW LEVEL SECURITY;

-- Políticas permisivas para la demo (acceso total con anon key)
CREATE POLICY "Allow all for demo" ON profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON groups FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON group_members FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON levels FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON questions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON student_progress FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON quiz_attempts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON rewards FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON purchased_rewards FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for demo" ON unlocked_cards FOR ALL USING (true) WITH CHECK (true);
