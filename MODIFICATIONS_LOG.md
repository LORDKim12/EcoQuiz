# EcoQuiz — Registro de Modificaciones para Agentes de IA

> **Última actualización:** 19 de mayo de 2026  
> **Versión:** 1.1.0 (Pre-BD)  
> **Propósito de este archivo:** Dar contexto completo a cualquier agente de IA que trabaje con este código.

---

## 📋 Descripción del Proyecto

**EcoQuiz** es una app educativa sobre la naturaleza y biodiversidad de México, diseñada para niños de **3° a 6° de primaria (8-10 años)**. Usa un sistema de niveles progresivos (tipo Candy Crush) donde los niños avanzan por biomas respondiendo preguntas y desbloqueando tarjetas de la enciclopedia.

- **Alineada con programas de la SEP**
- **Estado actual:** Demo funcional para presentación en clase
- **Plataformas:** Android, iOS, Web, macOS, Linux, Windows
- **Framework:** Flutter + Dart

---

## 🏗️ Arquitectura

### Patrón de estado (en migración)
- **Legacy:** Singleton `GameState` con `ValueNotifier<T>` — aún activo en las pantallas
- **Nuevo:** `flutter_riverpod` + **Repository Pattern** con interfaces de servicio
- Persistencia: `SharedPreferences` (local) → preparado para Supabase (producción)

### Estructura de carpetas
```
lib/
├── core/
│   ├── constants/app_colors.dart        # Paleta de colores centralizada
│   ├── theme/app_theme.dart             # Tema Material con Google Fonts (Nunito)
│   ├── models/                          # ← NUEVO: Modelos puros (sin Flutter)
│   │   ├── models.dart                  # Barrel file
│   │   ├── user_model.dart
│   │   ├── group_model.dart
│   │   ├── level_model.dart
│   │   ├── question_model.dart
│   │   ├── reward_model.dart
│   │   ├── quiz_attempt_model.dart
│   │   └── encyclopedia_card_model.dart
│   ├── services/                        # ← NUEVO: Interfaces (contratos)
│   │   ├── auth_service.dart
│   │   ├── student_service.dart
│   │   └── teacher_service.dart
│   ├── services/impl/                   # ← NUEVO: Implementaciones locales
│   │   ├── local_auth_service.dart
│   │   ├── local_student_service.dart
│   │   └── local_teacher_service.dart
│   └── providers/                       # ← NUEVO: Riverpod providers
│       └── service_providers.dart
├── features/
│   ├── home/                            # Pantalla de selección de rol
│   ├── student/                         # Todo el flujo del alumno
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── game_state.dart      # LEGACY Singleton (en migración)
│   │   │   │   └── quiz_model.dart      # LEGACY modelo de pregunta
│   │   │   └── data/
│   │   │       └── question_bank.dart   # 30 preguntas (5 por bioma)
│   │   └── presentation/
│   │       ├── screens/                 # Todas las pantallas del alumno
│   │       └── widgets/                 # Widgets reutilizables
│   └── teacher/                         # Todo el flujo del maestro
└── main.dart                            # Entry point + ProviderScope + layout responsive
```

---

## 🔧 Modificaciones Realizadas (Sesión Completa)

### 1. Banco de Preguntas Centralizado
**Archivo:** `lib/features/student/domain/data/question_bank.dart`  
**Qué se hizo:**
- Creé un repositorio central de **30 preguntas educativas** (5 por bioma)
- Biomas: Ciudad, Manglar, Arrecife, Bosque, Selva, Desierto
- Cada pregunta tiene: texto, 3 opciones, índice correcto, pista, dato curioso, imagen
- Se desacopló la lógica de preguntas del `student_map_screen.dart` (antes tenía 80+ líneas de `if/else`)

**Antes:** Preguntas hardcodeadas inline en la pantalla del mapa  
**Después:** `QuestionBank.getQuestionsForLevel(levelIndex)` retorna lista de `QuizQuestion`

### 2. Mecánica de Game Over
**Archivo:** `lib/features/student/presentation/screens/student_quiz_screen.dart`  
**Qué se hizo:**
- Cuando los corazones llegan a 0, aparece un diálogo amigable
- Opciones: "Intentar de nuevo" (restaura corazones, reinicia quiz) o "Volver al mapa"
- Los corazones ahora son funcionales (antes eran decorativos)

### 3. Temporizador por Pregunta
**Archivo:** `lib/features/student/presentation/screens/student_quiz_screen.dart`  
**Qué se hizo:**
- Cada pregunta tiene **30 segundos** para ser respondida
- Barra visual de tiempo que cambia de color: verde → amarillo → rojo
- Contador numérico visible en la esquina superior derecha
- Si se acaba el tiempo: se pierde 1 corazón y se muestra la respuesta correcta

### 4. Feedback Visual al Responder Mal
**Archivo:** `lib/features/student/presentation/screens/student_quiz_screen.dart`  
**Qué se hizo:**
- **Shake animation:** La tarjeta de opciones tiembla al seleccionar incorrectamente
- **Respuesta correcta resaltada:** Se muestra en verde con ✅ por 2 segundos
- **Respuesta incorrecta marcada:** Se muestra en rojo con ❌
- **Flash rojo:** El fondo cambia brevemente a rosa/rojo

### 5. Animaciones de Nivel Completado
**Archivo:** `lib/features/student/presentation/screens/student_level_complete_screen.dart`  
**Qué se hizo:**
- **Emoji 🎉** con bounce elástico + pulso continuo
- **Estrellas aparecen una por una** con animación spring
- **Tarjeta desbloqueada** entra desde abajo con rotación
- **Confeti explosivo** desde 2 puntos con partículas en forma de estrella (8 colores)
- **12 partículas flotantes** decorativas en el fondo
- **Botones** con slide-up suave
- **Mensajes contextuales** según estrellas ganadas

### 6. Animaciones de Respuesta Correcta
**Archivo:** `lib/features/student/presentation/screens/student_quiz_result_screen.dart`  
**Qué se hizo:**
- **Checkmark** con bounce elástico + brillo pulsante verde
- **"¡Correcto!"** con slide-in y emojis ⭐🎯
- **Avatar de Eco** con bounce
- **Tarjeta "¿Sabías que...?"** con slide-up
- Todos los elementos aparecen en **secuencia** (300ms de delay entre cada uno)

### 7. Panel de Configuración
**Archivo:** `lib/features/student/presentation/widgets/settings_bottom_sheet.dart`  
**Qué se hizo:**
- Bottom sheet deslizable con 6 opciones:
  - 🔊 Efectos de sonido (toggle — placeholder para futuro)
  - 📳 Vibración (toggle — placeholder para futuro)
  - ❤️ Restaurar corazones (útil para la demo)
  - 🔄 Reiniciar progreso (con diálogo de confirmación)
  - ℹ️ Acerca de EcoQuiz (versión, créditos, "Hecho en México 🇲🇽")
  - 🚪 Cerrar sesión
- Conecté el engrane ⚙️ de todas las pantallas del alumno

**Bug corregido:** El engrane del alumno en Journal y Perfil antes tenía `onPressed: () {}` (no hacía nada)

### 8. Nombre Personalizado
**Archivos:** `game_state.dart`, `student_login_screen.dart`, `student_profile_screen.dart`  
**Qué se hizo:**
- El campo "¿Cómo te llamas?" del login ahora guarda el nombre en `GameState`
- Se persiste con `SharedPreferences`
- El perfil y ranking muestran el nombre real en vez de "Juan Pérez" hardcodeado

### 9. Tienda de Premios (Awards)
**Archivo:** `lib/features/student/presentation/screens/student_awards_screen.dart`  
**Qué se hizo:**
- Los alumnos ahora pueden **gastar estrellas** en premios
- Diálogo de confirmación antes de comprar
- Premios comprados se marcan con ✅ verde
- Balance de estrellas visible en header
- Estado vacío amigable ("Tu maestro agregará premios pronto")
- Premios son los que el maestro agrega desde su panel

### 10. Método `resetAllProgress()` en GameState
**Archivo:** `lib/features/student/domain/models/game_state.dart`  
**Qué se hizo:**
- Limpia: tarjetas, estrellas, niveles, nombre, premios comprados
- Restaura corazones a 5/5
- Reinicia niveles (solo el primero desbloqueado)
- Útil para resetear entre alumnos durante la demo

### 11. Soporte Web/Desktop
**Archivos:** `main.dart`, `app_theme.dart`, `web/index.html`, `web/manifest.json`  
**Qué se hizo:**

#### `main.dart` — Layout responsive por plataforma
- **`_AppScrollBehavior`:** Scroll behavior personalizado que habilita drag con mouse en web (sin esto, los ScrollViews no se arrastran con mouse)
- **`_WebDesktopShell`:** En pantallas > 600px, la app se muestra dentro de un frame de teléfono con:
  - Fondo con gradiente y emojis decorativos de fauna mexicana
  - Branding "EcoQuiz" arriba-izquierda (pantallas > 800px)
  - Créditos SEP en la parte inferior
  - Bordes redondeados y sombra del frame
- **Móvil nativo:** Pantalla completa sin restricciones
- **Web en móvil:** Solo centra y limita ancho, sin frame decorativo

#### `app_theme.dart` — Tema adaptivo
- `GoogleFonts.config.allowRuntimeFetching = true` — las fuentes se descargan por HTTP en web
- `splashFactory: NoSplash.splashFactory` en web — quita el efecto ink splash de Material para que los taps se sientan más nativos en navegador

#### `web/index.html` — Pantalla de carga personalizada
- Loading screen con branding EcoQuiz (🌿 + barra animada + "Cargando tu aventura...")
- Fondo con gradiente que coincide con la app
- Meta tags SEO (description, keywords, author)
- Viewport anti-zoom en navegadores móviles
- Scrollbar personalizado (delgado, semi-transparente)
- Se oculta automáticamente cuando Flutter termina de cargar

#### `web/manifest.json`
- Nombre: "EcoQuiz — Naturaleza de México"
- Colores temáticos: `#27AE60` (verde), `#FDF8F5` (fondo)
- Descripción en español

### 12. Corrección del Borde Punteado
**Archivo:** `lib/features/student/presentation/widgets/encyclopedia_card.dart`  
**Qué se hizo:**
- `DashedRectPainter.paint()` estaba vacío — nunca dibujaba nada
- Implementé cálculo de path metrics para dibujar dashes reales
- Las tarjetas bloqueadas de la enciclopedia ahora muestran el borde punteado

### 13. Limpieza de Código
**Archivos eliminados:**
- `student_placeholder_screen.dart` — pantalla vacía sin uso
- `teacher_placeholder_screen.dart` — pantalla vacía sin uso
- `level_node_button.dart` — widget huérfano sin importar en ningún lado
- `map_path_painter.dart` — painter huérfano sin importar en ningún lado

### 14. Arquitectura para Base de Datos (Fase 1)
**Archivos nuevos:** 16 archivos en `lib/core/`  
**Qué se hizo:**

#### Modelos puros (`lib/core/models/`)
- `UserModel` — con rol (student/teacher), JSON serializable
- `GroupModel` — grupo escolar con código de acceso (ej. ECO-4A)
- `LevelModel` — nivel con bioma, orden, y estados
- `QuestionModel` — pregunta con UUID, FK a nivel
- `RewardModel` — premio con `iconName` (string) y `colorHex` (string), no `IconData`/`Color`
- `QuizAttemptModel` — registro de cada respuesta (analytics)
- `EncyclopediaCardModel` — tarjeta sin dependencias de Flutter

#### Interfaces de servicio (`lib/core/services/`)
- `AuthService` — login alumno, login maestro, logout, getCurrentUser
- `StudentService` — niveles, estrellas, corazones, recompensas, enciclopedia, reset
- `TeacherService` — grupos, alumnos, niveles, recompensas, progreso

#### Implementaciones locales (`lib/core/services/impl/`)
- `LocalAuthService` — auth con SharedPreferences (demo)
- `LocalStudentService` — envuelve la lógica actual de GameState
- `LocalTeacherService` — grupos/alumnos con SharedPreferences + mocks

#### Riverpod providers (`lib/core/providers/`)
- `authServiceProvider` → `LocalAuthService()`
- `studentServiceProvider` → `LocalStudentService()`  
- `teacherServiceProvider` → `LocalTeacherService()`
- **Para migrar a Supabase:** solo se cambian estas 3 líneas

#### main.dart
- Envuelto en `ProviderScope` para habilitar Riverpod
- `GameState.instance.init()` mantenido como legacy durante migración gradual

### 15. Integración Supabase — Opción C: Full (Fase 2-3)
**Archivos nuevos/modificados:** 10+ archivos  
**Qué se hizo:**

#### Backend Supabase
- Conectado a proyecto Supabase con 10 tablas
- `supabase_schema.sql` — esquema completo de la BD
- `supabase_seed_questions.sql` — 30 preguntas educativas

#### Implementaciones Supabase (`lib/core/services/impl/`)
- `SupabaseAuthService` — login alumno con código de grupo + nombre
- `SupabaseStudentService` — operaciones del alumno contra la BD
- `SupabaseTeacherService` — gestión de grupos, alumnos, niveles, recompensas

#### Pantallas migradas
- `student_login_screen.dart` → auth async con Supabase
- `teacher_login_screen.dart` → auth async con Supabase
- `teacher_group_management_screen.dart` → CRUD real contra BD
- `teacher_awards_management_screen.dart` → Premios en la BD
- **NUEVA:** `teacher_question_management_screen.dart` — maestro gestiona preguntas

---


## ⚠️ Problemas Conocidos / Deuda Técnica

| # | Problema | Severidad | Notas |
|---|---------|-----------|-------|
| 1 | `.withOpacity()` deprecado | Baja | Migrar a `.withValues()` — ~90 ocurrencias en todo el proyecto |
| 2 | `GameState` es Singleton | Media | Para producción, migrar a Provider/Riverpod |
| 3 | Toggles de sonido/vibración | Baja | Están en la UI pero no conectados a lógica real |
| 4 | `_recalculateTotalStars()` usa `forEach` | Baja | Lint recomienda usar `fold()` o `for` |
| 5 | Import no usado en test | Baja | `test/widget_test.dart:8` tiene un import sin usar |
| 6 | Cálculo de estrellas | Media | Basado en corazones restantes, no en % de aciertos |

---

## 📦 Dependencias

| Paquete | Versión | Uso | Compatible Web |
|---------|---------|-----|----------------|
| `shared_preferences` | ^2.2.3 | Persistencia local | ✅ (usa localStorage) |
| `flutter_riverpod` | ^3.3.1 | Estado + inyección de dependencias | ✅ |
| `confetti` | ^0.7.0 | Partículas de celebración | ✅ |
| `google_fonts` | ^6.2.1 | Tipografía Nunito | ✅ (descarga HTTP) |
| `fl_chart` | ^0.70.2 | Gráficas en dashboard maestro | ✅ |
| `provider` | ^6.1.2 | Legacy, se puede remover | ✅ |

---

## 🚀 Cómo Correr

```bash
# Móvil (iOS/Android)
flutter run

# Web (requiere Chrome o navegador)
flutter run -d web-server --web-port=8080
# Luego abrir http://localhost:8080

# Build web para hosting
flutter build web --no-tree-shake-icons
# Archivos en build/web/

# macOS desktop
flutter run -d macos
```

---

## 💡 Decisiones de Diseño

1. **Repository Pattern:** Interfaces abstractas (`AuthService`, `StudentService`, `TeacherService`) con implementaciones locales. Para migrar a Supabase, solo se crean nuevas implementaciones y se cambian 3 líneas en `service_providers.dart`.
2. **Riverpod sobre Provider:** Más testeable, con inyección de dependencias limpia y tipado fuerte.
3. **Modelos puros sin Flutter:** `RewardModel` usa `String iconName` y `String colorHex` en vez de `IconData`/`Color`. Facilita serialización a JSON/BD.
4. **GameState legacy convive:** No se eliminó para no romper las pantallas. Se eliminará cuando todas usen los nuevos providers.
5. **30 preguntas (5 por bioma):** Suficiente para demo. Para producción, las preguntas vendrán de la tabla `questions` en Supabase.
6. **Layout web como teléfono:** La app se muestra centrada como un teléfono para mantener la proporción en pantallas anchas.

---

## 🗺️ Próximos Pasos (Fase 2: Supabase)

1. Migrar pantallas de `GameState.instance.xxx` → `ref.watch(studentServiceProvider).xxx`
2. Crear `SupabaseAuthService`, `SupabaseStudentService`, `SupabaseTeacherService`
3. Cambiar las 3 líneas en `service_providers.dart`
4. Crear tablas en Supabase según el esquema ER del plan de migración
5. Implementar Row Level Security (RLS) para que maestros solo vean sus grupos

---

## 🛠️ Actualizaciones Recientes: Arquitectura de Mundos (Niveles Anidados por Biomas)

### Cambios en Estructura de Datos
1. **LevelData (GameState):** Se agregó el campo `biome` (String) para asociar cada nivel a un bioma particular. Se implementó retrocompatibilidad en el `.fromJson()` usando el título del nivel como bioma por defecto para niveles legacy.

### Vistas del Alumno
1. **StudentMapScreen (Reingeniería):**
   - Se migró de una sola lista vertical (`ListView.builder`) a un **Carrusel Horizontal (`PageView.builder`)**.
   - Cada página del carrusel representa un Bioma, mostrando la imagen real generada por IA (Tundra, Selva, Desierto, Bosque) a pantalla completa en el fondo.
   - El título del Bioma flota en la parte superior.
   - Los niveles (`LevelData`) ahora se filtran por Bioma en cada página y se renderizan sobre la imagen en su layout de zigzag (con la mascota ubicándose en el último nivel desbloqueado).
   - El usuario debe pasar niveles dentro del mismo bioma en el orden correspondiente.

### Vistas del Maestro
1. **TeacherLevelManagementScreen & Modal:**
   - La pantalla de gestión de niveles ahora utiliza un Modal interactivo (`_AddLevelModal`) segregado en un archivo (y luego adjunto) `teacher_level_management_screen_modal.dart` (luego refactorizado en `teacher_level_management_screen.dart`).
   - El modal contiene un selector en carrusel visual (`PageView`) de biomas que permite al maestro elegir gráficamente a qué mundo asignar el nuevo nivel.
   - Al guardar, el nivel se guarda con su bioma correspondiente.
2. **TeacherQuestionManagementScreen:**
   - Se actualizó el texto del `FilterChip` (selector de nivel horizontal superior) para mostrar explícitamente el nombre del bioma y nivel, por ejemplo: `TUNDRA - Nivel 1`.
   - Esto le da claridad al maestro para ubicar correctamente a qué sección (Bioma -> Nivel) está agregando las preguntas al banco local (Supabase).

### Activos (Assets) Generados
- Imágenes generadas mediante herramienta de IA (Text to Image) para ser usadas como texturas de mapas de biomas en pantalla completa:
  - `biome_tundra.png`
  - `biome_desert.png`
  - `biome_jungle.png`
  - `biome_forest.png`
- (Las imágenes fueron movidas al folder `assets/images/` y se pueden utilizar libremente para el mapa).

---

## 🛠️ Actualizaciones Recientes: Biomas Dinámicos y Nuevos Fondos

### Soporte a Nuevos Biomas y Assets
- Se generaron 3 nuevas imágenes de fondo por IA: `biome_city.png` (Ciudad), `biome_mangrove.png` (Manglar) y `biome_reef.png` (Arrecife).
- Se actualizó el mapa del alumno (`StudentMapScreen`) para soportar estos fondos. Al crear niveles asignados a "Ciudad", "Manglar" o "Arrecife", el carrusel renderizará automáticamente las imágenes correctas de fondo.

### Gestión Dinámica de Biomas (Maestro)
- En la pantalla `TeacherLevelManagementScreen`, el modal para crear niveles (`_AddLevelModal`) ahora recolecta dinámicamente cualquier bioma existente en el estado del juego (`GameState`). 
- Si el maestro crea niveles en biomas no estándar, estos aparecerán automáticamente en el carrusel de opciones para ser seleccionados.
- Se agregó una opción **"Otro (Nuevo)"** en el carrusel de selección, habilitando un campo de texto extra para que el maestro asigne libremente un nuevo nombre de bioma.

### Eliminación de Biomas
- Se agregó el botón (ícono de bote de basura rojo) en la pantalla `TeacherLevelManagementScreen` (esquina superior derecha).
- Al presionarlo, el sistema pregunta qué bioma eliminar.
- Al confirmar la eliminación, todos los niveles (y sus referencias) asociados a ese bioma se remueven del estado del juego (`deleteBiome` en `GameState`).

### 16. Sincronización GameState ↔ Supabase (Bugfixes)
**Problema:** Los premios canjeados por un alumno no se reflejaban en Supabase, y al cambiar de sesión (alumno→maestro), los datos se mezclaban.

#### Correcciones implementadas:
1. **`syncFromSupabase(studentId)`** — Nuevo método en `GameState` que carga niveles, premios, estrellas, corazones y compras desde Supabase al iniciar sesión. Ahora incluye el campo `biome`.
2. **Student login** — Ahora llama `await GameState.instance.syncFromSupabase(user.id)` después del login para que todas las pantallas muestren datos del servidor.
3. **`spendStars` → Supabase** — Al canjear un premio, ahora se escribe la compra en `purchased_rewards` de Supabase (fire-and-forget).
4. **`_recalculateTotalStars`** — Corregido para restar las estrellas gastadas en compras, evitando que se "restauren" al recargar.
5. **Campo `biome` en `LevelData`** — Todos los defaults, resets y syncs ahora usan el campo `biome` del usuario.
6. **`teacher_question_management_screen`** — Corregido para usar `l.biome` en vez de `l.title.toLowerCase()` al crear `LevelModel`.

---

### 17. Rediseño UI Premium: Gestión de Mundos + Limpieza de Código

#### UI Rediseñada (`teacher_level_management_screen.dart`)
- **Cards de bioma con gradiente**: Cada bioma tiene colores, emoji e ícono temáticos (Ciudad=🏙️, Manglar=🌿, Arrecife=🐠, Bosque=🌲, Selva=🦜, Desierto=🏜️, Tundra=❄️).
- **Swipe-to-delete**: Los niveles individuales se pueden eliminar deslizando a la izquierda (`Dismissible`).
- **PopupMenu** en header de bioma para eliminar mundo completo.
- **Diálogos estilizados**: Bordes redondeados (28px), iconos temáticos, colores consistentes con el bioma, campos con `filled: true`.
- **Validación de biomas duplicados**: Al crear un bioma verifica que no exista ya.
- **Nombre sugerido automático**: Al agregar nivel, sugiere "Nivel N+1".
- **SnackBars premium**: Floating, con iconos y bordes redondeados.

#### Código Muerto Eliminado
- `teacherService` (sin usar) en `teacher_question_management_screen.dart`
- `supabase` variable (sin usar) en `teacher_question_management_screen.dart`
- `correctOption` variable (sin usar) en `teacher_question_management_screen.dart`
- Import `teacher_level_management_screen` (sin usar) en `student_map_screen.dart`
- `_scrollController` campo (sin usar) en `student_map_screen.dart`
- Import `student_level_complete_screen` (sin usar) en `student_journal_screen.dart`
- Imports de interfaces abstractas (sin usar) en `service_providers.dart`
- Archivo `teacher_level_management_screen.dart.patch` eliminado

#### Resultado
- **0 errors**, **0 warnings** en `flutter analyze`
- Build web exitoso ✓
