# EcoQuiz — Registro de Modificaciones para Agentes de IA

> **Última actualización:** 14 de mayo de 2026  
> **Versión:** 1.0.0 (Demo)  
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

### Patrón de estado
- **Singleton `GameState`** (`lib/features/student/domain/models/game_state.dart`)
- Usa `ValueNotifier<T>` para reactividad (no Provider/Riverpod — decisión consciente para la demo)
- Persistencia con `SharedPreferences`

### Estructura de carpetas
```
lib/
├── core/
│   ├── constants/app_colors.dart    # Paleta de colores centralizada
│   └── theme/app_theme.dart         # Tema Material con Google Fonts (Nunito)
├── features/
│   ├── home/                        # Pantalla de selección de rol
│   ├── student/                     # Todo el flujo del alumno
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── game_state.dart  # Singleton: estado global del juego
│   │   │   │   └── quiz_model.dart  # Modelo de pregunta
│   │   │   └── data/
│   │   │       └── question_bank.dart # 30 preguntas (5 por bioma)
│   │   └── presentation/
│   │       ├── screens/             # Todas las pantallas del alumno
│   │       └── widgets/             # Widgets reutilizables
│   └── teacher/                     # Todo el flujo del maestro
└── main.dart                        # Entry point + layout responsive
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
| `confetti` | ^0.7.0 | Partículas de celebración | ✅ |
| `google_fonts` | ^6.2.1 | Tipografía Nunito | ✅ (descarga HTTP) |
| `fl_chart` | ^0.70.2 | Gráficas en dashboard maestro | ✅ |
| `provider` | ^6.1.2 | Declarado pero no usado activamente | ✅ |

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

1. **Singleton sobre Provider:** Se eligió por velocidad de desarrollo para la demo. No escala bien, migrar post-demo.
2. **30 preguntas (5 por bioma):** Suficiente para demo de ~5 minutos por nivel. Para producción, escalar a 10+ por nivel.
3. **Animaciones con `TickerProviderStateMixin`:** Se usan AnimationControllers manuales en vez de paquetes como `lottie` para mantener las dependencias mínimas.
4. **Temporizador de 30 segundos:** Equilibrio entre presión y accesibilidad para niños de 8-10 años.
5. **Layout web como teléfono:** La app está diseñada para móvil; en web se muestra centrada como un teléfono para mantener la proporción y no romper layouts.
6. **Emojis como decoración web:** Se usan emojis nativos (🌵🦎🐢) en vez de assets para evitar peso extra y mantener compatibilidad universal.
