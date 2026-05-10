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
              
              const Spacer(),
              // Ajolote mascot image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/eco_ajolote.png',
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Eco el Ajolote\n(Falta imagen)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
