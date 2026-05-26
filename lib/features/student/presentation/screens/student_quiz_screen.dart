import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/quiz_model.dart';
import 'package:provider/provider.dart';
import '../../domain/models/game_state.dart';
import 'student_quiz_result_screen.dart';
import 'student_level_complete_screen.dart';

class StudentQuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final int levelIndex; // To know which card to unlock
  final bool isTeacher;

  const StudentQuizScreen({super.key, required this.questions, required this.levelIndex, this.isTeacher = false});

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showHint = false;
  bool _wrongAnswerFlash = false;
  int? _selectedWrongIndex;
  bool _showCorrectAnswer = false;
  bool _answeredCorrectly = false;

  // Temporizador
  static const int _totalSeconds = 30;
  int _secondsRemaining = _totalSeconds;
  Timer? _timer;

  // Shake animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = _totalSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsRemaining--;
      });
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    context.read<GameState>().deductHeart();
    final remaining = context.read<GameState>().hearts;

    if (remaining <= 0) {
      _showGameOverDialog();
      return;
    }

    // Mostrar la respuesta correcta
    setState(() {
      _showCorrectAnswer = true;
      _wrongAnswerFlash = true;
    });

    // Esperar 2 segundos y avanzar
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _wrongAnswerFlash = false;
        _showCorrectAnswer = false;
        _selectedWrongIndex = null;
      });
      _moveToNextOrStay();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('⏰', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                '¡Se acabó el tiempo! Perdiste un corazón',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF39C12),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _moveToNextOrStay() {
    // En este quiz, el niño debe intentar de nuevo la misma pregunta si falla
    _startTimer();
  }

  void _onOptionSelected(int index) {
    if (_showCorrectAnswer || _answeredCorrectly) return; // Evitar doble tap

    final currentQuestion = widget.questions[_currentIndex];
    if (index == currentQuestion.correctOptionIndex) {
      _timer?.cancel();
      setState(() => _answeredCorrectly = true);

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
                  _answeredCorrectly = false;
                  _selectedWrongIndex = null;
                  _showCorrectAnswer = false;
                });
                _startTimer();
              } else {
                // Quiz finished, show level complete screen
                int earned = 1;
                final h = context.read<GameState>().hearts;
                if (h == 5) {
                  earned = 3;
                } else if (h >= 3) {
                  earned = 2;
                } else if (h <= 0) {
                  earned = 0;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentLevelCompleteScreen(
                      levelIndex: widget.levelIndex,
                      earnedStars: earned,
                      isTeacher: widget.isTeacher,
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
      // Wrong answer — deduct heart, shake, and show correct
      _timer?.cancel();
      if (!widget.isTeacher) {
        context.read<GameState>().deductHeart();
      }
      
      // Shake animation
      _shakeController.reset();
      _shakeController.forward();
      
      setState(() {
        _wrongAnswerFlash = true;
        _selectedWrongIndex = index;
        _showCorrectAnswer = true;
      });

      final remainingHearts = context.read<GameState>().hearts;

      // Game Over — sin corazones
      if (remainingHearts <= 0) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _showGameOverDialog();
        });
        return;
      }

      // Esperar 2 segundos mostrando la correcta, luego continuar
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _wrongAnswerFlash = false;
          _selectedWrongIndex = null;
          _showCorrectAnswer = false;
        });
        _startTimer();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.favorite, color: Color(0xFFE74C3C), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.isTeacher ? '¡Incorrecto!' : '¡Incorrecto! — ($remainingHearts ❤️ restantes)',
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
    _timer?.cancel();
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border, size: 40, color: Colors.red),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<GameState>().restoreHearts();
                    setState(() {
                      _currentIndex = 0;
                      _showHint = false;
                      _wrongAnswerFlash = false;
                      _selectedWrongIndex = null;
                      _showCorrectAnswer = false;
                      _answeredCorrectly = false;
                    });
                    _startTimer();
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<GameState>().restoreHearts();
                    Navigator.pop(context);
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3423)),
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

  Color _getOptionColor(int optionIndex) {
    final currentQuestion = widget.questions[_currentIndex];
    
    if (_showCorrectAnswer) {
      if (optionIndex == currentQuestion.correctOptionIndex) {
        return const Color(0xFF27AE60); // Verde brillante para la correcta
      }
      if (optionIndex == _selectedWrongIndex) {
        return const Color(0xFFE74C3C); // Rojo para la seleccionada incorrecta
      }
      return Colors.grey.shade400; // Gris para las demás
    }

    // Colores normales
    switch (optionIndex) {
      case 0: return const Color(0xFF4CAF50);
      case 1: return const Color(0xFF2196F3);
      case 2: return const Color(0xFFFF9800);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;
    final timerProgress = _secondsRemaining / _totalSeconds;
    final timerColor = _secondsRemaining <= 10
        ? const Color(0xFFE74C3C)
        : _secondsRemaining <= 20
            ? const Color(0xFFF39C12)
            : const Color(0xFF27AE60);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
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
          // Contador de vidas
          Consumer<GameState>(
            builder: (context, gameState, child) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE74C3C), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFFE74C3C), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${gameState.hearts}',
                      style: const TextStyle(
                        color: Color(0xFFE74C3C),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Temporizador visual
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: timerColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: timerColor, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: timerColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_secondsRemaining',
                  style: TextStyle(
                    color: timerColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Stack(
            children: [
              // Barra de progreso de preguntas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
                    minHeight: 4,
                  ),
                ),
              ),
              // Barra de temporizador debajo
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: timerProgress,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                    minHeight: 3,
                  ),
                ),
              ),
            ],
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
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.image, size: 50)),
                        );
                      },
                    ),
                  ),
                  
                  // Card for Question and Options con shake
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final shakeOffset = _shakeController.isAnimating
                          ? ((_shakeAnimation.value * 20) * ((_shakeAnimation.value * 10).round().isEven ? 1 : -1))
                          : 0.0;
                      return Transform.translate(
                        offset: Offset(shakeOffset, 0),
                        child: child,
                      );
                    },
                    child: Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E1),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBrown,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Option Buttons con colores dinámicos
                            _buildOptionButton(
                              text: currentQuestion.options[0],
                              color: _getOptionColor(0),
                              onTap: () => _onOptionSelected(0),
                              isCorrect: _showCorrectAnswer && 0 == currentQuestion.correctOptionIndex,
                              isWrong: _showCorrectAnswer && 0 == _selectedWrongIndex,
                            ),
                            const SizedBox(height: 12),
                            _buildOptionButton(
                              text: currentQuestion.options[1],
                              color: _getOptionColor(1),
                              onTap: () => _onOptionSelected(1),
                              isCorrect: _showCorrectAnswer && 1 == currentQuestion.correctOptionIndex,
                              isWrong: _showCorrectAnswer && 1 == _selectedWrongIndex,
                            ),
                            const SizedBox(height: 12),
                            
                            // Last option with Mascot hint stack
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.centerRight,
                              children: [
                                _buildOptionButton(
                                  text: currentQuestion.options[2],
                                  color: _getOptionColor(2),
                                  onTap: () => _onOptionSelected(2),
                                  isCorrect: _showCorrectAnswer && 2 == currentQuestion.correctOptionIndex,
                                  isWrong: _showCorrectAnswer && 2 == _selectedWrongIndex,
                                ),
                                
                                // Mascot hint button
                                Positioned(
                                  right: -10,
                                  bottom: -10,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _showHint = !_showHint),
                                    child: Container(
                                      width: 55,
                                      height: 55,
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
                                      constraints: const BoxConstraints(maxWidth: 200),
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
                                          fontSize: 13,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
    bool isCorrect = false,
    bool isWrong = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: (_showCorrectAnswer || _answeredCorrectly) ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            disabledBackgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isCorrect
                    ? const Color(0xFF1B5E20)
                    : isWrong
                        ? const Color(0xFFB71C1C)
                        : Colors.black.withValues(alpha: 0.1),
                width: (isCorrect || isWrong) ? 3 : 2,
              ),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCorrect) ...[
                const Icon(Icons.check_circle, color: Colors.white, size: 22),
                const SizedBox(width: 8),
              ],
              if (isWrong) ...[
                const Icon(Icons.cancel, color: Colors.white, size: 22),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
