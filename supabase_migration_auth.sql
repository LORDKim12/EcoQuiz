-- ═══════════════════════════════════════════════════════════════════
-- EcoQuiz: Migración para Login Funcional
-- Ejecutar en Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════════

-- 1. Agregar columnas de autenticación a profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT UNIQUE DEFAULT NULL;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pin TEXT DEFAULT NULL;

-- 2. Crear cuenta admin/maestro
INSERT INTO profiles (name, role, email, pin, hearts)
VALUES ('Administrador', 'teacher', 'admin@ecoquiz.mx', '1234', 5)
ON CONFLICT (email) DO UPDATE SET pin = '1234', name = 'Administrador';

-- 3. Crear grupo de prueba ECO-4A si no existe
DO $$
DECLARE
  teacher_uuid UUID;
  group_exists BOOLEAN;
BEGIN
  -- Obtener el ID del maestro admin
  SELECT id INTO teacher_uuid FROM profiles WHERE email = 'admin@ecoquiz.mx' LIMIT 1;
  
  -- Verificar si el grupo ya existe
  SELECT EXISTS(SELECT 1 FROM groups WHERE code = 'ECO-4A') INTO group_exists;
  
  IF NOT group_exists AND teacher_uuid IS NOT NULL THEN
    INSERT INTO groups (teacher_id, name, code) VALUES (teacher_uuid, 'Grupo 4A', 'ECO-4A');
  END IF;
END $$;

-- 4. Verificar que todo se creó correctamente
SELECT id, name, email, role, pin FROM profiles WHERE role = 'teacher';
SELECT id, name, code, teacher_id FROM groups WHERE code = 'ECO-4A';
