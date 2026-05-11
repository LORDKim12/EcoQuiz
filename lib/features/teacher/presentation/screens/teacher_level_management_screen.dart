import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../student/domain/models/game_state.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ValueListenableBuilder<List<bool>>(
            valueListenable: GameState.instance.unlockedLevels,
            builder: (context, unlockedLevels, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestión de\nNiveles',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.textBrown,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Controla el acceso a las diferentes zonas y niveles para tus alumnos.',
                          style: TextStyle(
                            color: AppColors.textDark.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Zones List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildZoneCard(5, 'Desierto de Sonora', Icons.park, const Color(0xFFFDE8E1), unlockedLevels),
                        const SizedBox(height: 16),
                        _buildZoneCard(4, 'Selva de Chiapas', Icons.eco, const Color(0xFF5ABF5A), unlockedLevels),
                        const SizedBox(height: 16),
                        _buildZoneCard(3, 'Bosque', Icons.emoji_nature, const Color(0xFF98FB98), unlockedLevels),
                        const SizedBox(height: 16),
                        _buildZoneCard(2, 'Arrecife', Icons.water, const Color(0xFFD6EAF8), unlockedLevels),
                        const SizedBox(height: 16),
                        _buildZoneCard(1, 'Manglar', Icons.filter_vintage, const Color(0xFFFFD1DC), unlockedLevels),
                        const SizedBox(height: 16),
                        _buildZoneCard(0, 'Ciudad', Icons.location_city, const Color(0xFFFFDAB9), unlockedLevels),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildZoneCard(int mapIndex, String title, IconData icon, Color headerColor, List<bool> unlockedLevels) {
    final isUnlocked = unlockedLevels[mapIndex];

    return Container(
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textDark, width: 1.5),
              ),
              child: Icon(icon, color: AppColors.textDark, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUnlocked ? const Color(0xFF1E5B1E) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isUnlocked ? null : Border.all(color: AppColors.textDark),
                    ),
                    child: Text(
                      isUnlocked ? 'DESBLOQUEADA' : 'BLOQUEADA',
                      style: TextStyle(
                        color: isUnlocked ? Colors.white : AppColors.textDark,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isUnlocked,
              onChanged: (val) {
                GameState.instance.setLevelUnlocked(mapIndex, val);
              },
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF1E5B1E), // Dark green
              inactiveThumbColor: Colors.grey.shade500,
              inactiveTrackColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
