import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/student/domain/models/game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final gameState = GameState();
  await gameState.init();

  // ── Supabase ─────────────────────────────────────────────────────────
  await Supabase.initialize(
    url: 'https://jsvwxceighiqslgkygow.supabase.co',
    anonKey: 'sb_publishable_jzMj4HyMNsv-EfPbPmwqsg_dH-0XveR',
  );

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: gameState),
        ],
        child: const EcoQuizApp(),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Scroll behavior personalizado: habilita drag con mouse en web/desktop.
// Sin esto, los ListViews/ScrollViews no se pueden arrastrar con el mouse.
// ─────────────────────────────────────────────────────────────────────────────
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // Permite arrastrar con mouse en web
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class EcoQuizApp extends StatelessWidget {
  const EcoQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoQuiz — Naturaleza de México',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      // ── Scroll: habilitar drag con mouse en web ──────────────────────
      scrollBehavior: const _AppScrollBehavior(),

      // ── Builder: layout adaptivo por plataforma ──────────────────────
      builder: (context, child) {
        final width = MediaQuery.of(context).size.width;

        // Web o desktop (pantalla ancha): mostrar shell decorativo
        if (kIsWeb || width > 600) {
          return _WebDesktopShell(child: child!);
        }

        // Móvil nativo: pantalla completa sin restricciones
        return child!;
      },

      home: const HomeScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHELL PARA WEB / DESKTOP
// Envuelve la app en un frame que simula un teléfono, con fondo decorativo,
// branding y créditos. Solo se muestra en pantallas > 600px o en web.
// ═══════════════════════════════════════════════════════════════════════════════
class _WebDesktopShell extends StatelessWidget {
  final Widget child;
  const _WebDesktopShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 800;

    // En web con pantalla angosta (ej. navegador de celular), no mostrar
    // el frame decorativo — solo limitar el ancho y centrar.
    if (screenWidth <= 600) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: child,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE2F4D8), // Verde claro
            Color(0xFFFDE8E1), // Rosa suave
            Color(0xFFD6EAF8), // Azul claro
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Partículas decorativas de fondo (solo pantallas amplias) ──
          if (isWideScreen) ..._buildBackgroundDecorations(),

          // ── Branding superior izquierdo ─────────────────────────────
          if (isWideScreen)
            Positioned(
              top: 30,
              left: 40,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EcoQuiz',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4A3423),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        'Aprende sobre la naturaleza de México',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7A8B7A),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // ── App centrada como teléfono ──────────────────────────────
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              // Margen proporcional al alto de pantalla
              margin: EdgeInsets.symmetric(
                vertical: screenHeight > 800 ? 24 : 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: child,
              ),
            ),
          ),

          // ── Créditos en la parte inferior ───────────────────────────
          if (isWideScreen)
            Positioned(
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, color: Colors.grey.shade500, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Alineado con programas de la SEP  •  3° a 6° de primaria  •  Hecho en México',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Emojis de fauna mexicana como decoración del fondo en pantallas amplias.
  List<Widget> _buildBackgroundDecorations() {
    final decorations = <Widget>[];
    final random = Random();

    // Lado izquierdo
    final leftItems = [
      (60.0, 200.0, Icons.eco, 28.0),
      (120.0, 600.0, Icons.bug_report, 24.0),
      (50.0, 400.0, Icons.local_florist, 22.0),
      (90.0, 750.0, Icons.pets, 26.0),
    ];

    for (int i = 0; i < leftItems.length; i++) {
      final item = leftItems[i];
      final left = item.$1;
      final top = item.$2;
      final seed = i * 100.0;
      final iconData = item.$3;
      final size = item.$4;

      decorations.add(
        Positioned(
          left: left,
          top: top,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 3000 + random.nextInt(2000)),
            curve: Curves.easeInOutSine,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  sin(value * pi * 2 + seed) * 15,
                  cos(value * pi * 2 + seed) * 15,
                ),
                child: Opacity(
                  opacity: (0.4 + sin(value * pi) * 0.4).clamp(0.2, 0.8),
                  child: Icon(iconData, size: size, color: Colors.green.withValues(alpha: 0.5)),
                ),
              );
            },
          ),
        ),
      );
    }

    // Lado derecho
    final rightItems = [
      (80.0, 150.0, Icons.emoji_nature, 26.0),
      (100.0, 350.0, Icons.park, 30.0),
      (60.0, 550.0, Icons.water, 24.0),
      (120.0, 700.0, Icons.filter_vintage, 28.0),
    ];

    for (int i = 0; i < rightItems.length; i++) {
      final item = rightItems[i];
      final right = item.$1;
      final top = item.$2;
      final seed = i * 100.0;
      final iconData = item.$3;
      final size = item.$4;

      decorations.add(
        Positioned(
          right: right,
          top: top,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 3000 + random.nextInt(2000)),
            curve: Curves.easeInOutSine,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  sin(value * pi * 2 + seed) * 15,
                  cos(value * pi * 2 + seed) * 15,
                ),
                child: Opacity(
                  opacity: (0.4 + sin(value * pi) * 0.4).clamp(0.2, 0.8),
                  child: Icon(iconData, size: size, color: Colors.green.withValues(alpha: 0.5)),
                ),
              );
            },
          ),
        ),
      );
    }

    return decorations;
  }
}
