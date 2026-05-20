import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../../../core/constants/app_colors.dart';
import 'student_journal_screen.dart';
import '../../domain/models/game_state.dart';

class StudentLevelCompleteScreen extends StatefulWidget {
  final int levelIndex;
  final int earnedStars;

  const StudentLevelCompleteScreen({
    super.key,
    required this.levelIndex,
    required this.earnedStars,
  });

  @override
  State<StudentLevelCompleteScreen> createState() => _StudentLevelCompleteScreenState();
}

class _StudentLevelCompleteScreenState extends State<StudentLevelCompleteScreen>
    with TickerProviderStateMixin {
  late EncyclopediaCardData cardData;
  late ConfettiController _confettiController;

  // Animaciones
  late AnimationController _titleController;
  late AnimationController _starsController;
  late AnimationController _cardController;
  late AnimationController _buttonsController;
  late AnimationController _pulseController;

  late Animation<double> _titleScale;
  late Animation<double> _cardSlide;
  late Animation<double> _cardRotation;
  late Animation<double> _buttonsSlide;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final safeCardIndex = widget.levelIndex % GameState.allCards.length;
    cardData = GameState.allCards[safeCardIndex];

    _confettiController = ConfettiController(duration: const Duration(seconds: 5));

    // Título: escala desde 0 con rebote
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleScale = CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    );

    // Estrellas: aparecen una por una
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Tarjeta: slide desde abajo con rotación
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardSlide = Tween<double>(begin: 300, end: 0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );
    _cardRotation = Tween<double>(begin: 0.15, end: -0.05).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    // Botones: slide desde abajo
    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonsSlide = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOutCubic),
    );

    // Pulso continuo para el trofeo/título
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Secuencia de animaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GameState.instance.unlockCard(safeCardIndex);
      GameState.instance.saveStarsForLevel(widget.levelIndex, widget.earnedStars);

      if (widget.earnedStars > 0) {
        GameState.instance.setLevelUnlocked(widget.levelIndex + 1, true);
      }

      GameState.instance.restoreHearts();

      // Disparar animaciones en secuencia
      _confettiController.play();
      _titleController.forward();

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _starsController.forward();
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _cardController.forward();
      });
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) _buttonsController.forward();
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _titleController.dispose();
    _starsController.dispose();
    _cardController.dispose();
    _buttonsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Partículas flotantes de fondo ─────────────────────────────
          ..._buildFloatingParticles(),

          // ── Contenido principal ───────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // ── Emoji de celebración animado ─────────────────────
                    ScaleTransition(
                      scale: _titleScale,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        ),
                        child: const Text(
                          '🎉',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Título con rebote ────────────────────────────────
                    ScaleTransition(
                      scale: _titleScale,
                      child: Text(
                        '¡Completaste el\nNivel ${widget.levelIndex + 1}!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBrown,
                          height: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Estrellas animadas una por una ───────────────────
                    AnimatedBuilder(
                      animation: _starsController,
                      builder: (context, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final bool isEarned = i < widget.earnedStars;
                            // Cada estrella aparece en un tercio del timeline
                            final starDelay = i / 3.0;
                            final starProgress = ((_starsController.value - starDelay) / 0.33).clamp(0.0, 1.0);
                            final scale = isEarned
                                ? Curves.elasticOut.transform(starProgress)
                                : Curves.easeOut.transform(starProgress);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Transform.scale(
                                scale: scale,
                                child: Icon(
                                  isEarned ? Icons.star : Icons.star_border,
                                  color: isEarned
                                      ? const Color(0xFFF39C12)
                                      : Colors.grey.shade400,
                                  size: 64,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // ── Subtítulo ──────────────────────────────────
                    ScaleTransition(
                      scale: _titleScale,
                      child: Text(
                        _getStarsMessage(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── "Nueva tarjeta descubierta" ─────────────────────
                    AnimatedBuilder(
                      animation: _cardController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _cardSlide.value),
                          child: Opacity(
                            opacity: (_cardController.value * 2).clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, color: Color(0xFFF39C12), size: 22),
                              SizedBox(width: 8),
                              Text(
                                '¡Nueva tarjeta descubierta!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E4E42),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.auto_awesome, color: Color(0xFF2B9BF4), size: 22),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Tarjeta con rotación ─────────────────────────
                          AnimatedBuilder(
                            animation: _cardRotation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _cardRotation.value,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 260,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCEAE5),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: const Color(0xFF7A8B7A),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7A8B7A).withValues(alpha: 0.3),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      cardData.imagePath,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                        height: 200,
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: Icon(Icons.image, size: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    cardData.title,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cardData.subtitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Botones con slide-up ─────────────────────────────
                    AnimatedBuilder(
                      animation: _buttonsController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _buttonsSlide.value),
                          child: Opacity(
                            opacity: _buttonsController.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // Botón "Siguiente nivel"
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F641B),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                                shadowColor: const Color(0xFF0F641B).withValues(alpha: 0.4),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Siguiente nivel',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botón "Ver enciclopedia"
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StudentJournalScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2B9BF4),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                                shadowColor: const Color(0xFF2B9BF4).withValues(alpha: 0.4),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.menu_book, color: Colors.white, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    'Ver enciclopedia',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // ── Confetti explosivo desde dos lados ────────────────────────
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.04,
                  numberOfParticles: 25,
                  maxBlastForce: 40,
                  minBlastForce: 15,
                  gravity: 0.2,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFF27AE60),
                    Color(0xFFF39C12),
                    Color(0xFF2B9BF4),
                    Color(0xFFE74C3C),
                    Color(0xFF9B59B6),
                    Colors.white,
                    Color(0xFFFF6B81),
                    Color(0xFF1ABC9C),
                  ],
                  createParticlePath: (size) {
                    // Mezcla de formas: estrellas y círculos
                    final random = Random();
                    if (random.nextBool()) {
                      return _drawStar(size);
                    }
                    return Path()
                      ..addOval(Rect.fromCircle(
                          center: Offset.zero, radius: size.width / 2));
                  },
                ),
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.04,
                  numberOfParticles: 25,
                  maxBlastForce: 40,
                  minBlastForce: 15,
                  gravity: 0.2,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFF27AE60),
                    Color(0xFFF39C12),
                    Color(0xFF2B9BF4),
                    Color(0xFFE74C3C),
                    Color(0xFF9B59B6),
                    Colors.white,
                    Color(0xFFFF6B81),
                    Color(0xFF1ABC9C),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Genera partículas flotantes decorativas de fondo
  List<Widget> _buildFloatingParticles() {
    final random = Random(42); // Seed fijo para consistencia
    final colors = [
      const Color(0xFF27AE60),
      const Color(0xFFF39C12),
      const Color(0xFF2B9BF4),
      const Color(0xFFE74C3C),
      const Color(0xFF9B59B6),
    ];

    return List.generate(12, (i) {
      final left = random.nextDouble() * 400;
      final top = random.nextDouble() * 800;
      final size = 6.0 + random.nextDouble() * 10;
      final color = colors[i % colors.length];

      return Positioned(
        left: left,
        top: top,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 2000 + random.nextInt(2000)),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: (0.15 + value * 0.2).clamp(0.0, 0.35),
              child: Transform.translate(
                offset: Offset(0, sin(value * pi * 2) * 10),
                child: child,
              ),
            );
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    });
  }

  /// Dibuja una forma de estrella para las partículas de confeti
  Path _drawStar(Size size) {
    final path = Path();
    final center = Offset.zero;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2.5;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 2 * pi / 5) - pi / 2;
      final innerAngle = ((i + 0.5) * 2 * pi / 5) - pi / 2;

      final outerPoint = Offset(
        center.dx + outerRadius * cos(outerAngle),
        center.dy + outerRadius * sin(outerAngle),
      );
      final innerPoint = Offset(
        center.dx + innerRadius * cos(innerAngle),
        center.dy + innerRadius * sin(innerAngle),
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    return path;
  }

  String _getStarsMessage() {
    switch (widget.earnedStars) {
      case 3:
        return '¡Perfecto! 🌟 ¡Eres un explorador experto!';
      case 2:
        return '¡Muy bien! 💪 ¡Sigue así, explorador!';
      case 1:
        return '¡Buen intento! 🌱 ¡Puedes mejorar!';
      default:
        return '¡No te rindas! 💚 ¡Inténtalo de nuevo!';
    }
  }
}
