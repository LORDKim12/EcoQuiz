import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../student/domain/models/game_state.dart';

class TeacherAwardsManagementScreen extends StatefulWidget {
  const TeacherAwardsManagementScreen({super.key});

  @override
  State<TeacherAwardsManagementScreen> createState() => _TeacherAwardsManagementScreenState();
}

class _TeacherAwardsManagementScreenState extends State<TeacherAwardsManagementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  void _showAddRewardDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Agregar Nuevo Premio', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título del premio', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(labelText: 'Subtítulo', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Costo (Estrellas)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final cost = int.tryParse(_costController.text) ?? 50;
                if (_titleController.text.isNotEmpty) {
                  final icons = [Icons.card_giftcard, Icons.star, Icons.videogame_asset, Icons.color_lens];
                  final colors = [0xFF8E44AD, 0xFFE67E22, 0xFF27AE60, 0xFF2B9BF4];
                  
                  final newReward = RewardData(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text.trim(),
                    subtitle: _subtitleController.text.trim().isEmpty ? 'Premio especial' : _subtitleController.text.trim(),
                    cost: cost,
                    colorValue: colors[Random().nextInt(colors.length)],
                    iconCodePoint: icons[Random().nextInt(icons.length)].codePoint,
                  );
                  
                  GameState.instance.addReward(newReward);
                  _titleController.clear();
                  _subtitleController.clear();
                  _costController.clear();
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
        onPressed: _showAddRewardDialog,
        backgroundColor: const Color(0xFF2B9BF4),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Premio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          'Gestión de Premios',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textBrown,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Agrega o elimina los premios de la tienda.',
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
            Expanded(
              child: ValueListenableBuilder<List<RewardData>>(
                valueListenable: GameState.instance.rewards,
                builder: (context, rewards, child) {
                  if (rewards.isEmpty) {
                    return const Center(child: Text('No hay premios registrados.'));
                  }
                  
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: rewards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Color(reward.colorValue).withOpacity(0.2),
                            child: Icon(IconData(reward.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(reward.colorValue)),
                          ),
                          title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${reward.subtitle} • ⭐️ ${reward.cost}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              GameState.instance.removeReward(reward.id);
                            },
                          ),
                        ),
                      );
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
}
