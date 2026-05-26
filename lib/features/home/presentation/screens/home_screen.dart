import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/mode_selection_button.dart';
import '../../../student/presentation/screens/student_login_screen.dart';
import '../../../teacher/presentation/screens/teacher_login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder for Logo/Icon
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.studentBorder,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: AppColors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'EcoQuiz',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.studentBorder,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.studentBorder),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                '¡Hola Aventurero!',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '¿Cómo quieres explorar hoy?',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ModeSelectionButton(
                title: 'Modo Alumno',
                subtitle: '¡Juega, explora y gana medallas!',
                icon: Icons.emoji_people,
                backgroundColor: AppColors.studentPrimary,
                borderColor: AppColors.studentBorder,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentLoginScreen(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              ModeSelectionButton(
                title: 'Modo Maestro',
                subtitle: 'Crea misiones y revisa el progreso.',
                icon: Icons.school,
                backgroundColor: AppColors.teacherPrimary,
                borderColor: AppColors.teacherBorder,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeacherLoginScreen(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              // Ajolote mascot image
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/eco_ajolote_mascot.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.studentPrimary,
                        child: const Icon(Icons.pets, size: 60, color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
