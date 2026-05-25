import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../student/domain/models/game_state.dart';
import 'teacher_question_management_screen.dart';
import 'teacher_expedition_wizard_screen.dart';

class TeacherLevelManagementScreen extends StatefulWidget {
  const TeacherLevelManagementScreen({super.key});

  @override
  State<TeacherLevelManagementScreen> createState() =>
      _TeacherLevelManagementScreenState();
}

class _TeacherLevelManagementScreenState
    extends State<TeacherLevelManagementScreen> {

  String _getBiomeImage(String biome) {
    final lower = biome.toLowerCase();
    if (lower.contains('tundra') || lower.contains('nieve')) {
      return 'assets/images/biome_tundra.png';
    } else if (lower.contains('desierto') || lower.contains('arena')) {
      return 'assets/images/biome_desert.png';
    } else if (lower.contains('selva') || lower.contains('jungla')) {
      return 'assets/images/biome_jungle.png';
    } else if (lower.contains('bosque') || lower.contains('pradera')) {
      return 'assets/images/biome_forest.png';
    } else if (lower.contains('ciudad') || lower.contains('urbe')) {
      return 'assets/images/biome_city.png';
    } else if (lower.contains('manglar') || lower.contains('pantano')) {
      return 'assets/images/biome_mangrove.png';
    } else if (lower.contains('arrecife') || lower.contains('oceano') || lower.contains('mar')) {
      return 'assets/images/biome_reef.png';
    }
    return 'assets/images/biome_forest.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_expedition',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const TeacherExpeditionWizardScreen()),
          );
        },
        backgroundColor: const Color(0xFF27AE60),
        icon: const Icon(Icons.explore, color: Colors.white),
        label: const Text('Nueva Expedición',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                          'Mis Expediciones',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.textBrown,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gestiona las aventuras de tus alumnos',
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

            // Expeditions List
            Expanded(
              child: Consumer<GameState>(
                builder: (context, gameState, child) {
                  final levels = gameState.levels;

                  if (levels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.explore_off,
                              size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No hay expediciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea tu primera expedición con el botón +',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(bottom: 100),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      return _buildExpeditionCard(context, level);
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

  Widget _buildExpeditionCard(BuildContext context, LevelData level) {
    final biomeImage =
        level.backgroundImagePath ?? _getBiomeImage(level.biome);
    final hasStops = level.hasStops;
    final stopCount = hasStops ? level.stops.length : 0;
    final questionCount = hasStops
        ? level.stops.fold<int>(0, (sum, s) => sum + s.questions.length)
        : level.questions.length;
    final isOriginal = level.id <= 5;

    return GestureDetector(
      onTap: () {
        if (isOriginal) {
          // Niveles originales → ir al editor de preguntas
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherQuestionManagementScreen(
                  initialLevelId: level.id),
            ),
          );
        } else {
          // Expediciones custom → ir al editor de preguntas
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherQuestionManagementScreen(
                  initialLevelId: level.id),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background biome image
              Image.asset(
                biomeImage,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF27AE60),
                ),
              ),

              // Dark gradient overlay for readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: badges
                    Row(
                      children: [
                        // Biome badge
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                level.biome,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isOriginal)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Original',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        // Active switch
                        const SizedBox(width: 8),
                        Transform.scale(
                          scale: 0.75,
                          child: Switch(
                            value: level.isUnlocked,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF27AE60),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.3),
                            onChanged: (val) {
                              context
                                  .read<GameState>()
                                  .setLevelUnlocked(level.id, val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Bottom: title and stats
                    Text(
                      level.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black38, blurRadius: 4)
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (hasStops) ...[
                          const Icon(Icons.flag,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '$stopCount parada${stopCount != 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        const Icon(Icons.quiz,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$questionCount pregunta${questionCount != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.white54, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
