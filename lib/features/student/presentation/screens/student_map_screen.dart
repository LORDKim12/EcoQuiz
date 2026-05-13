import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/game_state.dart';
import '../../domain/data/question_bank.dart';
import 'student_quiz_screen.dart';
import '../../../teacher/presentation/screens/teacher_level_management_screen.dart';

class StudentMapScreen extends StatefulWidget {
  final bool isTeacher;
  const StudentMapScreen({super.key, this.isTeacher = false});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  final ScrollController _scrollController = ScrollController();

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
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFE67E22), // Desert orange
              Color(0xFFF1C40F), // Sand yellow
              Color(0xFF27AE60), // Jungle green
              Color(0xFF1E8449), // Deep jungle
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: ValueListenableBuilder<List<LevelData>>(
          valueListenable: GameState.instance.levels,
          builder: (context, levels, child) {
            final int highestUnlockedIndex = levels.lastIndexWhere((l) => l.isUnlocked);
            
            return ListView.builder(
              controller: _scrollController,
              reverse: true, // Empieza desde abajo
              padding: const EdgeInsets.only(top: 120, bottom: 80),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                
                LevelStatus status = level.isUnlocked ? LevelStatus.completed : LevelStatus.locked;
                int stars = 0;
                
                if (level.isUnlocked) {
                  // Obtain stars from GameState
                  stars = GameState.instance.levelStars.value[level.id.toString()] ?? 0;
                }
                
                if (index == highestUnlockedIndex) {
                  status = LevelStatus.current;
                  stars = 0;
                }

                // Zigzag pattern
                final isLeft = index % 2 == 0;
                
                return SizedBox(
                  height: 140, // Height for each row
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Draw path line to the next node (except for the last one)
                      if (index < levels.length - 1)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _PathPainter(isLeftToRight: isLeft),
                          ),
                        ),
                        
                      // The Node
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
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Mascot floating near current level
                      if (index == highestUnlockedIndex)
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
                                errorBuilder: (_, __, ___) => Container(color: Colors.pink.shade200),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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
        color: AppColors.backgroundLight.withOpacity(0.95),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
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
          ValueListenableBuilder<int>(
            valueListenable: GameState.instance.hearts,
            builder: (context, heartsCount, child) {
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
          const SizedBox(width: 8),
          // Star Counter Pill
          ValueListenableBuilder<int>(
            valueListenable: GameState.instance.totalStars,
            builder: (context, stars, child) {
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
          if (widget.isTeacher) const SizedBox(width: 12),
          // Settings Icon for Teacher
          if (widget.isTeacher)
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherLevelManagementScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.settings, color: AppColors.textDark, size: 24),
              ),
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
      ..color = const Color(0xFFFAE5D3).withOpacity(0.5)
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
