import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/models/models.dart';
import '../../../student/domain/models/game_state.dart';

class TeacherAwardsManagementScreen extends ConsumerStatefulWidget {
  const TeacherAwardsManagementScreen({super.key});

  @override
  ConsumerState<TeacherAwardsManagementScreen> createState() => _TeacherAwardsManagementScreenState();
}

class _TeacherAwardsManagementScreenState extends ConsumerState<TeacherAwardsManagementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  List<RewardModel> _rewards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    setState(() => _isLoading = true);
    try {
      final teacherService = ref.read(teacherServiceProvider);
      _rewards = await teacherService.getRewards();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddRewardDialog() {
    _titleController.clear();
    _subtitleController.clear();
    _costController.clear();
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
              onPressed: () async {
                final cost = int.tryParse(_costController.text) ?? 50;
                if (_titleController.text.isNotEmpty) {
                  final iconNames = ['card_giftcard', 'star', 'videogame_asset', 'color_lens'];
                  final colorHexes = ['#8E44AD', '#E67E22', '#27AE60', '#2B9BF4'];
                  final rand = Random();

                  final newReward = RewardModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text.trim(),
                    subtitle: _subtitleController.text.trim().isEmpty
                        ? 'Premio especial'
                        : _subtitleController.text.trim(),
                    cost: cost,
                    iconName: iconNames[rand.nextInt(iconNames.length)],
                    colorHex: colorHexes[rand.nextInt(colorHexes.length)],
                  );

                  Navigator.pop(context);
                  try {
                    final teacherService = ref.read(teacherServiceProvider);
                    await teacherService.addReward(newReward);

                    // También sincronizar con GameState legacy
                    GameState.instance.addReward(RewardData(
                      id: newReward.id,
                      title: newReward.title,
                      subtitle: newReward.subtitle,
                      cost: newReward.cost,
                      colorValue: _hexToColor(newReward.colorHex),
                      iconCodePoint: Icons.card_giftcard.codePoint,
                    ));

                    await _loadRewards();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Premio agregado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
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

  int _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }

  static const _iconMap = {
    'card_giftcard': Icons.card_giftcard,
    'star': Icons.star,
    'videogame_asset': Icons.videogame_asset,
    'color_lens': Icons.color_lens,
    'face': Icons.face,
    'lightbulb': Icons.lightbulb,
    'wallpaper': Icons.wallpaper,
    'crop_square': Icons.crop_square,
  };

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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _rewards.isEmpty
                      ? const Center(child: Text('No hay premios registrados.'))
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: _rewards.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final reward = _rewards[index];
                            final color = Color(_hexToColor(reward.colorHex));
                            final icon = _iconMap[reward.iconName] ?? Icons.card_giftcard;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.2),
                                  child: Icon(icon, color: color),
                                ),
                                title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${reward.subtitle} • ⭐️ ${reward.cost}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    try {
                                      final teacherService = ref.read(teacherServiceProvider);
                                      await teacherService.removeReward(reward.id);
                                      await _loadRewards();
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
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
