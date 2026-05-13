import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/quiz_model.dart';
import '../../domain/models/game_state.dart';
import 'student_quiz_result_screen.dart';
import 'student_level_complete_screen.dart';

class StudentQuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final int levelIndex; // To know which card to unlock

  const StudentQuizScreen({super.key, required this.questions, required this.levelIndex});

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  int _currentIndex = 0;
  bool _showHint = false;
  bool _wrongAnswerFlash = false;

  void _onOptionSelected(int index) {
    final currentQuestion = widget.questions[_currentIndex];
    if (index == currentQuestion.correctOptionIndex) {
      // Navigate to correct answer screen
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => StudentQuizResultScreen(
            question: currentQuestion,
            onNext: () {
              Navigator.pop(context); // Pop result screen
              if (_currentIndex < widget.questions.length - 1) {
                setState(() {
                  _currentIndex++;
                  _showHint = false;
                });
              } else {
                // Quiz finished, show level complete screen
                int earned = 1;
                final h = GameState.instance.hearts.value;
                if (h == 5) earned = 3;
                else if (h >= 3) earned = 2;
                else if (h <= 0) earned = 0;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentLevelCompleteScreen(
                      levelIndex: widget.levelIndex,
                      earnedStars: earned,
                    ),
                  ),
                );
              }
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      // Wrong answer — deduct heart and flash red
      GameState.instance.deductHeart();
      setState(() => _wrongAnswerFlash = true);
      
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _wrongAnswerFlash = false);
      });

      final remainingHearts = GameState.instance.hearts.value;

      // Game Over — sin corazones
      if (remainingHearts <= 0) {
        _showGameOverDialog();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.favorite, color: Color(0xFFE74C3C), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Incorrecto — ¡Perdiste un corazón! ($remainingHearts ❤️ restantes)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFDE8E1),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDE8E1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Sad heart icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('💔', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Se acabaron tus\ncorazones!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A3423),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No te preocupes, todos los exploradores necesitan descansar. ¡Inténtalo de nuevo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 24),
              // Intentar de nuevo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Cerrar diálogo
                    GameState.instance.restoreHearts();
                    setState(() {
                      _currentIndex = 0;
                      _showHint = false;
                      _wrongAnswerFlash = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Intentar de nuevo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Volver al mapa
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Cerrar diálogo
                    GameState.instance.restoreHearts();
                    Navigator.pop(context); // Salir del quiz
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF4A3423), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, color: Color(0xFF4A3423), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Volver al mapa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3423),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pregunta ${_currentIndex + 1} de ${widget.questions.length}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          // Hearts row inside AppBar actions
          ValueListenableBuilder<int>(
            valueListenable: GameState.instance.hearts,
            builder: (context, h, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) => Icon(
                    i < h ? Icons.favorite : Icons.favorite_border,
                    color: i < h ? const Color(0xFFE74C3C) : Colors.grey.shade300,
                    size: 20,
                  )),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)), // Green
                minHeight: 4,
              ),
            ),
          ),
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _wrongAnswerFlash ? const Color(0xFFFFCDD2) : const Color(0xFFFDF8F5),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Top Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      currentQuestion.imageAssetPath,
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 350,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.image, size: 50)),
                        );
                      },
                    ),
                  ),
                  
                  // Card for Question and Options
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E1), // Light peach
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, -10),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentQuestion.questionText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textBrown,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Option Buttons
                          _buildOptionButton(
                            text: currentQuestion.options[0],
                            color: const Color(0xFF4CAF50), // Green
                            onTap: () => _onOptionSelected(0),
                          ),
                          const SizedBox(height: 12),
                          _buildOptionButton(
                            text: currentQuestion.options[1],
                            color: const Color(0xFF2196F3), // Blue
                            onTap: () => _onOptionSelected(1),
                          ),
                          const SizedBox(height: 12),
                          
                          // Last option with Mascot hint stack
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerRight,
                            children: [
                              _buildOptionButton(
                                text: currentQuestion.options[2],
                                color: const Color(0xFFFF9800), // Orange
                                onTap: () => _onOptionSelected(2),
                              ),
                              
                              // Mascot hint button
                              Positioned(
                                right: -10,
                                bottom: -10,
                                child: GestureDetector(
                                  onTap: () => setState(() => _showHint = !_showHint),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width: 2),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                                      ],
                                      image: const DecorationImage(
                                        image: AssetImage('assets/images/eco_ajolote_mascot.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Hint Tooltip
                              if (_showHint)
                                Positioned(
                                  right: 60,
                                  bottom: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey.shade400, width: 2),
                                    ),
                                    child: Text(
                                      currentQuestion.hint,
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
    );
  }

  Widget _buildOptionButton({required String text, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.black.withOpacity(0.1), width: 2),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark, // Dark text like in the design
          ),
        ),
      ),
    );
  }
}
