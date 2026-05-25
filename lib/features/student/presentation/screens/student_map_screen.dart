import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../domain/models/game_state.dart';
import '../../domain/data/question_bank.dart';
import 'student_quiz_screen.dart';

class StudentMapScreen extends StatefulWidget {
  final bool isTeacher;
  const StudentMapScreen({super.key, this.isTeacher = false});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {

  String _getBiomeImage(String title) {
    final lower = title.toLowerCase();
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
    // Fallback: Forest
    return 'assets/images/biome_forest.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _buildCustomAppBar(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E8449), // Fallback de color por si acaso
        ),
        child: Consumer<GameState>(
          builder: (context, gameState, child) {
            final levels = gameState.levels;
            final biomes = levels.map((l) => l.biome).toSet().toList();
            if (biomes.isEmpty) return const Center(child: Text('No hay biomas'));
            
            return PageView.builder(
              itemCount: biomes.length,
              itemBuilder: (context, index) {
                final biome = biomes[index];
                final biomeLevels = levels.where((l) => l.biome == biome).toList();
                
                // Buscar el nivel más alto desbloqueado globalmente
                final int highestUnlockedOverallIndex = levels.lastIndexWhere((l) => l.isUnlocked);
                final highestUnlockedOverallLevel = highestUnlockedOverallIndex >= 0 ? levels[highestUnlockedOverallIndex] : null;
                
                return Stack(
                  children: [
                    // Fondo del Bioma
                    Positioned.fill(
                      child: Image.asset(
                        _getBiomeImage(biome),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Título del Bioma flotante
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            biome.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                    // Niveles dentro de este bioma
                    Positioned.fill(
                      child: ListView.builder(
                        reverse: true, // Empieza desde abajo
                        padding: const EdgeInsets.only(top: 180, bottom: 80),
                        itemCount: biomeLevels.length,
                        itemBuilder: (context, bIndex) {
                          final level = biomeLevels[bIndex];
                          
                          LevelStatus status = level.isUnlocked ? LevelStatus.completed : LevelStatus.locked;
                          int stars = 0;
                          
                          if (level.isUnlocked) {
                            stars = gameState.levelStars[level.id.toString()] ?? 0;
                          }
                          
                          if (highestUnlockedOverallLevel?.id == level.id && stars == 0) {
                            status = LevelStatus.current;
                          }

                          final isLeft = bIndex % 2 == 0;
                          
                          return SizedBox(
                            height: 140, // Altura de cada fila
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Línea punteada
                                if (bIndex < biomeLevels.length - 1)
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _PathPainter(isLeftToRight: isLeft),
                                    ),
                                  ),
                                  
                                // Botón del Nivel
                                Align(
                                  alignment: isLeft ? const Alignment(-0.5, 0) : const Alignment(0.5, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        level.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LevelNodeButton(
                                        levelNumber: level.id + 1,
                                        status: status,
                                        stars: stars,
                                        onTap: () {
                                          if (status != LevelStatus.locked) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => StudentQuizScreen(
                                                    questions: QuestionBank.getForBiome(level.id),
                                                    levelIndex: level.id,
                                                    isTeacher: widget.isTeacher,
                                                  ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Mascota
                                if (highestUnlockedOverallLevel?.id == level.id)
                                  Positioned(
                                    left: isLeft ? MediaQuery.of(context).size.width * 0.25 - 50 : MediaQuery.of(context).size.width * 0.75 - 50,
                                    top: -20,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/eco_ajolote_mascot.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.pink.shade200),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }


  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
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
          // Hearts Counter Pill
          if (!widget.isTeacher)
            Consumer<GameState>(
              builder: (context, gameState, child) {
                final heartsCount = gameState.hearts;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF922B21), width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$heartsCount',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (!widget.isTeacher)
            const SizedBox(width: 8),
          // Star Counter Pill
          if (!widget.isTeacher)
            Consumer<GameState>(
              builder: (context, gameState, child) {
                final stars = gameState.totalStars;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF39C12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF873600), width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_border, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$stars',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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

// Pintor para dibujar el camino en zigzag
class _PathPainter extends CustomPainter {
  final bool isLeftToRight;

  _PathPainter({required this.isLeftToRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFAE5D3).withValues(alpha: 0.5)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // El mapa se dibuja de abajo hacia arriba en ListView.builder con reverse:true, 
    // pero cada celda se dibuja de arriba a abajo en sus coordenadas locales.
    // Queremos unir el nodo de esta celda con el nodo de la celda "siguiente" (que está arriba visualmente).
    
    double startX = isLeftToRight ? size.width * 0.25 : size.width * 0.75;
    double endX = isLeftToRight ? size.width * 0.75 : size.width * 0.25;
    
    // De la mitad de esta celda a la mitad de la celda de arriba (que en coords es y negativo, pero el canvas está cortado).
    // Mejor dibujamos una curva suave hacia arriba.
    path.moveTo(startX, size.height / 2);
    
    // Curva de bezier
    path.quadraticBezierTo(
      size.width / 2, size.height / 2, // control point
      endX, -size.height / 2,           // end point (center of the next cell up)
    );

    // Dibujar línea punteada
    final dashWidth = 10.0;
    final dashSpace = 10.0;
    double distance = 0.0;
    
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum LevelStatus { locked, current, completed }

class LevelNodeButton extends StatefulWidget {
  final int levelNumber;
  final LevelStatus status;
  final int stars;
  final VoidCallback onTap;

  const LevelNodeButton({
    super.key,
    required this.levelNumber,
    required this.status,
    required this.stars,
    required this.onTap,
  });

  @override
  State<LevelNodeButton> createState() => _LevelNodeButtonState();
}

class _LevelNodeButtonState extends State<LevelNodeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
    final bool isCurrent = widget.status == LevelStatus.current;
    final bool isLocked = widget.status == LevelStatus.locked;
    final bool isCompleted = widget.status == LevelStatus.completed;

    Color nodeColor = Colors.grey.shade400;
    Color shadowColor = Colors.grey.shade500;
    IconData? nodeIcon = Icons.lock;

    if (isCompleted) {
      nodeColor = AppColors.studentPrimary; // Green
      shadowColor = AppColors.studentBorder;
      nodeIcon = Icons.star;
    } else if (isCurrent) {
      nodeColor = const Color(0xFFF39C12); // Orange/Gold
      shadowColor = const Color(0xFFD35400);
      nodeIcon = Icons.play_arrow;
    }

    Widget node = GestureDetector(
      onTap: isLocked ? null : widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Sombra 3D
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: shadowColor,
              shape: BoxShape.circle,
            ),
          ),
          // Botón principal
          Transform.translate(
            offset: const Offset(0, -6),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: nodeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: isCurrent
                    ? Text(
                        '${widget.levelNumber}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      )
                    : Icon(nodeIcon, color: Colors.white, size: 32),
              ),
            ),
          ),
          
          // Estrellas (solo si está completado)
          if (isCompleted)
            Positioned(
              bottom: -15,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final bool earned = index < widget.stars;
                  return Icon(
                    earned ? Icons.star : Icons.star_border,
                    color: earned ? const Color(0xFFFFD700) : Colors.white70,
                    size: 20,
                    shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
                  );
                }),
              ),
            ),
        ],
      ),
    );

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

    return node;
  }
}
