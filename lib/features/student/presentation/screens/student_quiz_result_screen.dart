import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/quiz_model.dart';

class StudentQuizResultScreen extends StatefulWidget {
  final QuizQuestion question;
  final VoidCallback onNext;

  const StudentQuizResultScreen({
    super.key,
    required this.question,
    required this.onNext,
  });

  @override
  State<StudentQuizResultScreen> createState() => _StudentQuizResultScreenState();
}

class _StudentQuizResultScreenState extends State<StudentQuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _textController;
  late AnimationController _avatarController;
  late AnimationController _cardController;
  late AnimationController _buttonController;
  late AnimationController _glowController;

  late Animation<double> _checkScale;
  late Animation<double> _textSlide;
  late Animation<double> _avatarScale;
  late Animation<double> _cardSlide;
  late Animation<double> _buttonSlide;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Checkmark: escala con rebote elástico
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    // Texto "¡Correcto!": slide desde arriba
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textSlide = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    // Avatar de Eco: escala con bounce
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _avatarScale = CurvedAnimation(
      parent: _avatarController,
      curve: Curves.elasticOut,
    );

    // Tarjeta de dato curioso: slide desde abajo
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardSlide = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    // Botón siguiente: slide desde abajo
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic),
    );

    // Brillo pulsante del checkmark
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    // Secuencia de entrada
    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _avatarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _cardController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _textController.dispose();
    _avatarController.dispose();
    _cardController.dispose();
    _buttonController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // ── Checkmark animado con glow ─────────────────────────
                ScaleTransition(
                  scale: _checkScale,
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF1E5B1E), width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF27AE60)
                                  .withValues(alpha: _glowAnimation.value),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.check_rounded,
                              color: Colors.white, size: 65),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ── "¡Correcto!" con slide ──────────────────────────────
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Opacity(
                        opacity: _textController.value,
                        child: child,
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 30),
                      SizedBox(width: 8),
                      Text(
                        '¡Correcto!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E5B1E),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.track_changes, size: 30, color: Colors.orange),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ── Avatar de Eco celebrando con bounce ─────────────────
                ScaleTransition(
                  scale: _avatarScale,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF2980B9), width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2980B9).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage(
                            'assets/images/quiz_axolotl_safari_1778457587988.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ── Tarjeta "¿Sabías que...?" con slide-up ──────────────
                AnimatedBuilder(
                  animation: _cardController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _cardSlide.value),
                      child: Opacity(
                        opacity: _cardController.value,
                        child: child,
                      ),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            top: 30, left: 24, right: 24, bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAD7A1),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                              color: const Color(0xFF8B4513), width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B4513).withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¿Sabías que...?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.question.funFact,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.pets,
                                    color: Color(0xFF8B4513), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Dato asombroso',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF8B4513)
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Ícono flotante de foco
                      Positioned(
                        top: -20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE67E22),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF8B4513), width: 4),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFFE67E22).withValues(alpha: 0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.lightbulb,
                              color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Botón siguiente con slide-up ────────────────────────
                AnimatedBuilder(
                  animation: _buttonController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _buttonSlide.value),
                      child: Opacity(
                        opacity: _buttonController.value,
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006400),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor:
                            const Color(0xFF006400).withValues(alpha: 0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Siguiente pregunta',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
