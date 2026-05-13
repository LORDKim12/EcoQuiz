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

class _StudentLevelCompleteScreenState extends State<StudentLevelCompleteScreen> {
  late EncyclopediaCardData cardData;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Fetch a fallback card if the dynamic level exceeds hardcoded cards
    final safeCardIndex = widget.levelIndex % GameState.allCards.length;
    cardData = GameState.allCards[safeCardIndex];
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GameState.instance.unlockCard(safeCardIndex);
      GameState.instance.saveStarsForLevel(widget.levelIndex, widget.earnedStars);
      
      // If student passes next level unlock (only if not failed)
      if (widget.earnedStars > 0) {
         GameState.instance.setLevelUnlocked(widget.levelIndex + 1, true);
      }
      
      GameState.instance.restoreHearts();
      if (widget.earnedStars > 0) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Main scrollable content ──────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Floating dark green dot
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(left: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E8449),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      '¡Completaste el Nivel ${widget.levelIndex + 1}!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBrown,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Stars Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final bool isEarned = i < widget.earnedStars;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            isEarned ? Icons.star : Icons.star_border,
                            color: isEarned ? const Color(0xFFF39C12) : Colors.grey.shade400,
                            size: 60,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 40),

                    // Floating light green dot
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.lightGreenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Subtitle
                    const Text(
                      '¡Nueva tarjeta descubierta!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E4E42),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tilted Card
                    Transform.rotate(
                      angle: -0.05,
                      child: Container(
                        width: 250,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEAE5),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: const Color(0xFF7A8B7A), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
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
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Colors.grey.shade300,
                                  child: const Center(child: Icon(Icons.image, size: 50)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              cardData.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBrown,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Siguiente Nivel Button
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
                          elevation: 0,
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

                    // Ver enciclopedia Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudentJournalScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B9BF4),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: Colors.black.withOpacity(0.1), width: 2),
                          ),
                          elevation: 0,
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
            ),
          ),

          // ── Confetti from top-center ─────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.directional,
                  blastDirection: pi / 2, // straight down
                  emissionFrequency: 0.06,
                  numberOfParticles: 20,
                  maxBlastForce: 30,
                  minBlastForce: 10,
                  gravity: 0.3,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFF27AE60),
                    Color(0xFFF39C12),
                    Color(0xFF2B9BF4),
                    Color(0xFFFCEAE5),
                    Color(0xFFE74C3C),
                    Colors.white,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
