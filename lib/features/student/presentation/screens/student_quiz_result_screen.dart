import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/quiz_model.dart';

class StudentQuizResultScreen extends StatelessWidget {
  final QuizQuestion question;
  final VoidCallback onNext;

  const StudentQuizResultScreen({
    super.key,
    required this.question,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5), // Light pinkish background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Big Checkmark
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E5B1E), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF27AE60).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 16),
              // Correcto Text
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, color: Color(0xFFF39C12), size: 40),
                  SizedBox(width: 8),
                  Text(
                    '¡Correcto!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E5B1E), // Dark green text
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star_border, color: Color(0xFF3498DB), size: 50),
                ],
              ),
              const SizedBox(height: 40),
              
              // Avatar Circle
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2980B9), width: 6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/quiz_axolotl_safari_1778457587988.png'), // Safari axolotl
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Sabias que Card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 30, left: 24, right: 24, bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAD7A1), // Light orange/peach
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFF8B4513), width: 4), // Brown border
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
                          question.funFact,
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
                            const Icon(Icons.pets, color: Color(0xFF8B4513), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Dato asombroso',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8B4513).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Floating Bulb Icon
                  Positioned(
                    top: -20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE67E22), // Orange
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF8B4513), width: 4),
                      ),
                      child: const Icon(Icons.lightbulb_outline, color: Colors.black, size: 28),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006400), // Dark green button
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
                        'Siguiente pregunta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
