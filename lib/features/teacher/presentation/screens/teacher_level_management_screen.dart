import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../student/domain/models/game_state.dart';
import 'teacher_question_management_screen.dart';

class TeacherLevelManagementScreen extends StatefulWidget {
  const TeacherLevelManagementScreen({super.key});

  @override
  State<TeacherLevelManagementScreen> createState() => _TeacherLevelManagementScreenState();
}

class _TeacherLevelManagementScreenState extends State<TeacherLevelManagementScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a la pantalla de creación de nivel con preguntas
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeacherQuestionManagementScreen()),
          );
        },
        backgroundColor: const Color(0xFF2B9BF4),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Nivel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestión de Niveles',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textBrown,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Controla y crea niveles con preguntas.',
                          style: TextStyle(
                            color: AppColors.textDark.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Zones List
            Expanded(
              child: Consumer<GameState>(
                builder: (context, gameState, child) {
                  final levels = gameState.levels;
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8).copyWith(bottom: 80),
                    itemCount: levels.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      // Mostrar del último al primero
                      final level = levels[levels.length - 1 - index];
                      return _buildZoneCard(context, level);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard(BuildContext context, LevelData level) {
    final isUnlocked = level.isUnlocked;
    final hasCustomQuestions = level.questions.isNotEmpty;
    final hasBackground = level.backgroundPath != null;
    
    // Asignar colores basados en ID
    final colors = [
      const Color(0xFFFDE8E1), const Color(0xFF5ABF5A), 
      const Color(0xFF98FB98), const Color(0xFFD6EAF8), 
      const Color(0xFFFFD1DC), const Color(0xFFFFDAB9),
      const Color(0xFFD5F5E3), const Color(0xFFFEF9E7)
    ];
    final color = colors[level.id % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: hasBackground
                  ? const Icon(Icons.image, color: Color(0xFF2B9BF4), size: 28)
                  : Icon(Icons.terrain, color: AppColors.textBrown.withValues(alpha: 0.7), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nivel ${level.id + 1}: ${level.title}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        isUnlocked ? 'Activo' : 'Bloqueado',
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnlocked ? const Color(0xFF1E8449) : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasCustomQuestions) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF39C12).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${level.questions.length} preguntas',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD35400),
                            ),
                          ),
                        ),
                      ],
                      if (!hasCustomQuestions && level.id <= 5) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Bioma original',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E8449),
                            ),
                          ),
                        ),
                      ],
                      if (hasBackground) ...[
                        const SizedBox(width: 6),
                        const Text('🖼️', style: TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Custom Switch
            Switch(
              value: isUnlocked,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF27AE60),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade400,
              onChanged: (val) {
                context.read<GameState>().setLevelUnlocked(level.id, val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
