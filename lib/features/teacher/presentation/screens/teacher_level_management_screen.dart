import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../student/domain/models/game_state.dart';

class TeacherLevelManagementScreen extends StatefulWidget {
  const TeacherLevelManagementScreen({super.key});

  @override
  State<TeacherLevelManagementScreen> createState() => _TeacherLevelManagementScreenState();
}

class _TeacherLevelManagementScreenState extends State<TeacherLevelManagementScreen> {
  final TextEditingController _titleController = TextEditingController();

  void _showAddLevelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Agregar Nuevo Nivel', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Nombre del Bioma (ej. Tundra)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  GameState.instance.addLevel(_titleController.text.trim());
                  _titleController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B9BF4)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLevelDialog,
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
                          'Controla y crea niveles.',
                          style: TextStyle(
                            color: AppColors.textDark.withOpacity(0.8),
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
              child: ValueListenableBuilder<List<LevelData>>(
                valueListenable: GameState.instance.levels,
                builder: (context, levels, child) {
                  // Mostrar en orden reverso para que el más nuevo salga hasta arriba si se quiere,
                  // o mostrar en orden ascendente (0 a N).
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: levels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      // Vamos a mostrar del último al primero
                      final level = levels[levels.length - 1 - index];
                      return _buildZoneCard(level);
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

  Widget _buildZoneCard(LevelData level) {
    final isUnlocked = level.isUnlocked;
    
    // Asignar colores aleatorios o predefinidos basados en ID
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.terrain, color: AppColors.textBrown.withOpacity(0.7), size: 28),
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
                  Text(
                    isUnlocked ? 'Activo para alumnos' : 'Bloqueado',
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnlocked ? const Color(0xFF1E8449) : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Custom Switch
            Switch(
              value: isUnlocked,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF27AE60), // Green when active
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade400,
              onChanged: (val) {
                GameState.instance.setLevelUnlocked(level.id, val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
