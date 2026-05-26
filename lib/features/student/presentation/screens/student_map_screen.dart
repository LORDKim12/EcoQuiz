import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/quiz_model.dart';
import '../../domain/data/question_bank.dart';
import 'student_quiz_screen.dart';

class StudentMapScreen extends StatefulWidget {
  final bool isTeacher;
  const StudentMapScreen({super.key, this.isTeacher = false});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  int _currentBiomeIndex = 0;
  final PageController _biomePageController = PageController();

  String _safeBiomeName(String raw) {
    if (raw.trim().startsWith('{')) {
      try {
        final map = jsonDecode(raw);
        return map['biome']?.toString() ?? 'Bioma';
      } catch (_) {}
    }
    return raw;
  }

  String _getBiomeImage(String biome) {
    final lower = biome.toLowerCase();
    if (lower.contains('tundra') || lower.contains('nieve') || lower.contains('hielo')) {
      return 'assets/images/biome_tundra.png';
    } else if (lower.contains('desierto') || lower.contains('arena')) {
      return 'assets/images/biome_desert.png';
    } else if (lower.contains('selva') || lower.contains('jungla')) {
      return 'assets/images/biome_jungle.png';
    } else if (lower.contains('bosque') || lower.contains('pradera')) {
      return 'assets/images/biome_forest.png';
    } else if (lower.contains('ciudad') || lower.contains('urbe')) {
      return 'assets/images/biome_city.png';
    } else if (lower.contains('manglar') || lower.contains('pantano')) {
      return 'assets/images/biome_mangrove.png';
    } else if (lower.contains('arrecife') || lower.contains('oceano') || lower.contains('mar')) {
      return 'assets/images/biome_reef.png';
    }
    return 'assets/images/biome_forest.png';
  }

  @override
  void dispose() {
    _biomePageController.dispose();
    super.dispose();
  }

  /// Agrupa los niveles por bioma, manteniendo el orden.
  Map<String, List<LevelData>> _groupByBiome(List<LevelData> levels) {
    final grouped = <String, List<LevelData>>{};
    for (final level in levels) {
      final biomeName = _safeBiomeName(level.biome);
      grouped.putIfAbsent(biomeName, () => []);
      grouped[biomeName]!.add(level);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _buildCustomAppBar(context),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final allLevels = gameState.levels;
          if (allLevels.isEmpty) {
            return const Center(child: Text('No hay expediciones'));
          }

          final biomeGroups = _groupByBiome(allLevels);
          final biomeNames = biomeGroups.keys.toList();

          // Asegurar que el índice no se pase
          if (_currentBiomeIndex >= biomeNames.length) {
            _currentBiomeIndex = 0;
          }

          return Stack(
            children: [
              // Mapa principal con PageView por BIOMA
              PageView.builder(
                controller: _biomePageController,
                itemCount: biomeNames.length,
                onPageChanged: (index) {
                  setState(() => _currentBiomeIndex = index);
                },
                itemBuilder: (context, index) {
                  final biomeName = biomeNames[index];
                  final biomeLevels = biomeGroups[biomeName]!;
                  return _buildBiomeMap(context, biomeName, biomeLevels, gameState);
                },
              ),

              // Selector inferior de biomas
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBiomeSelector(biomeNames, biomeGroups),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Mapa de un bioma con TODOS sus niveles como nodos verticales
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBiomeMap(
    BuildContext context,
    String biomeName,
    List<LevelData> biomeLevels,
    GameState gameState,
  ) {
    final biomeImage = _getBiomeImage(biomeName);
    final int nodeCount = biomeLevels.length;

    // Crear lista de nodos (stops) a partir de los niveles del bioma
    final stops = <_StopInfo>[];
    for (int i = 0; i < biomeLevels.length; i++) {
      final level = biomeLevels[i];
      final stars = gameState.levelStars[level.id.toString()] ?? 0;
      final isCompleted = level.isUnlocked && stars > 0;

      // El nivel actual es el primero desbloqueado que no tiene estrellas
      final isCurrent = level.isUnlocked && stars == 0;

      // Obtener preguntas: primero del level, luego del QuestionBank
      List<QuizQuestion> questions;
      if (level.hasStops && level.stops.isNotEmpty) {
        // Si tiene stops configurados, usar todas las preguntas de los stops
        questions = level.stops.expand((s) => s.questions).toList();
      } else if (level.questions.isNotEmpty) {
        questions = level.questions;
      } else {
        questions = QuestionBank.getForBiome(level.id, gameState);
      }

      stops.add(_StopInfo(
        index: i,
        title: level.title,
        levelId: level.id,
        status: isCompleted
            ? _StopStatus.completed
            : isCurrent
                ? _StopStatus.current
                : _StopStatus.locked,
        stars: stars,
        questions: questions,
      ));
    }

    // Asegurar que al menos el primer nivel esté desbloqueado
    if (stops.isNotEmpty && !stops.any((s) => s.status != _StopStatus.locked)) {
      stops[0] = _StopInfo(
        index: 0,
        title: stops[0].title,
        levelId: stops[0].levelId,
        status: _StopStatus.current,
        stars: 0,
        questions: stops[0].questions,
      );
    }

    // Dimensiones del mapa
    final screenWidth = MediaQuery.of(context).size.width;
    final mapHeight = max(
      MediaQuery.of(context).size.height * 1.3,
      (nodeCount * 160.0) + 300,
    );

    // Generar posiciones de nodos en curva S de abajo hacia arriba
    final positions = _generateCurvePositions(nodeCount, screenWidth, mapHeight);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      reverse: true, // Empezar desde abajo (donde inicia el camino)
      child: SizedBox(
        width: screenWidth,
        height: mapHeight,
        child: Stack(
          children: [
            // Fondo del bioma
            Positioned.fill(
              child: Image.asset(
                biomeImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, _) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2ECC71), Color(0xFF1E8449)],
                    ),
                  ),
                ),
              ),
            ),

            // Overlay semi-transparente para legibilidad
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ),

            // Camino punteado entre nodos
            if (positions.length > 1)
              Positioned.fill(
                child: CustomPaint(
                  painter: _AdventurePathPainter(positions: positions),
                ),
              ),

            // Título del bioma (glassmorphism) — abajo porque el scroll es reverse
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.explore,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              biomeName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                      color: Colors.black38, blurRadius: 4)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Nodos de niveles
            ...List.generate(stops.length, (i) {
              final pos = positions[i];
              final stop = stops[i];
              return Positioned(
                left: pos.dx - 45,
                top: pos.dy - 45,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Etiqueta del nivel
                    if (stop.status != _StopStatus.locked)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stop.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 4)
                            ],
                          ),
                        ),
                      ),
                    // Botón del nodo
                    _StopNodeWidget(
                      stopNumber: i + 1,
                      status: stop.status,
                      stars: stop.stars,
                      onTap: () {
                        if (stop.status == _StopStatus.locked) return;
                        if (stop.questions.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Este nivel aún no tiene preguntas',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: const Color(0xFFF39C12),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentQuizScreen(
                              questions: stop.questions,
                              levelIndex: stop.levelId,
                              isTeacher: widget.isTeacher,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),

            // Mascota ajolote — junto al nodo actual
            ..._buildMascot(stops, positions),
          ],
        ),
      ),
    );
  }

  /// Genera posiciones distribuidas en una curva S sinusoidal de abajo hacia arriba.
  List<Offset> _generateCurvePositions(
      int count, double width, double mapHeight) {
    if (count == 0) return [];
    if (count == 1) {
      return [Offset(width / 2, mapHeight - 200)];
    }

    final positions = <Offset>[];
    final amplitude = width * 0.22;
    final centerX = width / 2;
    final topPadding = 200.0;
    final bottomPadding = 200.0;
    final usableHeight = mapHeight - topPadding - bottomPadding;

    for (int i = 0; i < count; i++) {
      final t = i / (count - 1);
      final y = mapHeight - bottomPadding - (usableHeight * t);
      final x = centerX + sin(t * pi * 2) * amplitude;
      positions.add(Offset(x.clamp(60, width - 60), y));
    }
    return positions;
  }

  /// Construye la mascota ajolote posicionada junto al nodo "actual"
  List<Widget> _buildMascot(List<_StopInfo> stops, List<Offset> positions) {
    final currentIndex =
        stops.indexWhere((s) => s.status == _StopStatus.current);
    if (currentIndex < 0 || currentIndex >= positions.length) return [];

    final pos = positions[currentIndex];
    final mascotX = pos.dx > MediaQuery.of(context).size.width / 2
        ? pos.dx - 110
        : pos.dx + 60;

    return [
      Positioned(
        left: mascotX,
        top: pos.dy - 80,
        child: Column(
          children: [
            // Burbuja de diálogo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                '¡Vamos, explorador! 🌟',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.textBrown,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Ajolote mascota
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/eco_ajolote_mascot.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, _) =>
                      Container(color: Colors.pink.shade200),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════
  // Selector inferior de biomas
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBiomeSelector(
      List<String> biomeNames, Map<String, List<LevelData>> biomeGroups) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15), width: 1),
            ),
          ),
          child: SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: biomeNames.length,
              itemBuilder: (context, index) {
                final biomeName = biomeNames[index];
                final isActive = index == _currentBiomeIndex;
                final levelCount = biomeGroups[biomeName]?.length ?? 0;
                return GestureDetector(
                  onTap: () {
                    _biomePageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.15),
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.explore,
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                          size: 18,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          biomeName,
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            fontWeight:
                                isActive ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '$levelCount ${levelCount == 1 ? 'nivel' : 'niveles'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Custom App Bar
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.studentBorder,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
          Text(
            'EcoQuiz',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.studentBorder,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Spacer(),
          // Hearts Counter
          if (!widget.isTeacher)
            Consumer<GameState>(
              builder: (context, gameState, child) {
                final heartsCount = gameState.hearts;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFF922B21), width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$heartsCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (!widget.isTeacher) const SizedBox(width: 8),
          // Star Counter
          if (!widget.isTeacher)
            Consumer<GameState>(
              builder: (context, gameState, child) {
                final stars = gameState.totalStars;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF39C12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFF873600), width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_border,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$stars',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Adventure Path Painter — dibuja una curva suave punteada entre los nodos
// ═══════════════════════════════════════════════════════════════════════════════
class _AdventurePathPainter extends CustomPainter {
  final List<Offset> positions;

  _AdventurePathPainter({required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    path.moveTo(positions[0].dx, positions[0].dy);

    for (int i = 1; i < positions.length; i++) {
      final prev = positions[i - 1];
      final curr = positions[i];
      final controlX = (prev.dx + curr.dx) / 2;
      path.quadraticBezierTo(controlX, prev.dy, curr.dx, curr.dy);
    }

    _drawDashedPath(canvas, path, shadowPaint, 14, 10);
    _drawDashedPath(canvas, path, paint, 12, 8);
  }

  void _drawDashedPath(
      Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AdventurePathPainter oldDelegate) =>
      oldDelegate.positions != positions;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Stop Status & Info
// ═══════════════════════════════════════════════════════════════════════════════
enum _StopStatus { locked, current, completed }

class _StopInfo {
  final int index;
  final String title;
  final int levelId;
  final _StopStatus status;
  final int stars;
  final List<QuizQuestion> questions;

  const _StopInfo({
    required this.index,
    required this.title,
    required this.levelId,
    required this.status,
    required this.stars,
    required this.questions,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// Stop Node Widget — nodo animado con heartbeat para el nodo actual
// ═══════════════════════════════════════════════════════════════════════════════
class _StopNodeWidget extends StatefulWidget {
  final int stopNumber;
  final _StopStatus status;
  final int stars;
  final VoidCallback onTap;

  const _StopNodeWidget({
    required this.stopNumber,
    required this.status,
    required this.stars,
    required this.onTap,
  });

  @override
  State<_StopNodeWidget> createState() => _StopNodeWidgetState();
}

class _StopNodeWidgetState extends State<_StopNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = widget.status == _StopStatus.current;
    final isLocked = widget.status == _StopStatus.locked;
    final isCompleted = widget.status == _StopStatus.completed;

    Color nodeColor;
    Color shadowColor;
    Color borderColor;
    IconData nodeIcon;

    if (isCompleted) {
      nodeColor = const Color(0xFF27AE60);
      shadowColor = const Color(0xFF1E8449);
      borderColor = Colors.white;
      nodeIcon = Icons.check;
    } else if (isCurrent) {
      nodeColor = const Color(0xFFF39C12);
      shadowColor = const Color(0xFFD35400);
      borderColor = Colors.white;
      nodeIcon = Icons.play_arrow;
    } else {
      nodeColor = const Color(0xFF95A5A6);
      shadowColor = const Color(0xFF7F8C8D);
      borderColor = Colors.grey.shade400;
      nodeIcon = Icons.lock;
    }

    Widget node = GestureDetector(
      onTap: isLocked ? null : widget.onTap,
      child: SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Glow effect for current
            if (isCurrent)
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) => Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF39C12)
                            .withValues(alpha: _glowAnimation.value),
                        blurRadius: 24,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

            // 3D shadow
            Positioned(
              top: 6,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: shadowColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main button
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: isLocked
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          nodeColor,
                          nodeColor.withValues(alpha: 0.8),
                        ],
                      ),
                color: isLocked ? nodeColor : null,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 4),
                boxShadow: [
                  if (!isLocked)
                    BoxShadow(
                      color: nodeColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Center(
                child: isCurrent
                    ? Text(
                        '${widget.stopNumber}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 4)
                          ],
                        ),
                      )
                    : Icon(nodeIcon, color: Colors.white, size: 30),
              ),
            ),

            // Stars (completed only)
            if (isCompleted)
              Positioned(
                bottom: -2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final bool earned = index < widget.stars;
                    return Icon(
                      earned ? Icons.star : Icons.star_border,
                      color: earned
                          ? const Color(0xFFFFD700)
                          : Colors.white70,
                      size: 20,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 2)
                      ],
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );

    // Heartbeat animation for current
    if (isCurrent) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: node,
      );
    }

    // Greyscale + reduced opacity for locked
    if (isLocked) {
      return Opacity(
        opacity: 0.5,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.saturation,
          ),
          child: node,
        ),
      );
    }

    return node;
  }
}
