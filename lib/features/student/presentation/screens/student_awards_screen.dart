import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart' as prov;
import '../../domain/models/game_state.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/models/models.dart';

class StudentAwardsScreen extends ConsumerStatefulWidget {
  final bool isTeacher;
  const StudentAwardsScreen({super.key, this.isTeacher = false});

  @override
  ConsumerState<StudentAwardsScreen> createState() => _StudentAwardsScreenState();
}

class _StudentAwardsScreenState extends ConsumerState<StudentAwardsScreen> {
  bool _isLoadingGroups = false;
  List<GroupModel> _groups = [];
  GroupModel? _selectedGroup;
  List<RewardModel> _teacherRewards = [];
  bool _isLoadingRewards = false;

  @override
  void initState() {
    super.initState();
    if (widget.isTeacher) {
      _loadTeacherData();
    }
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoadingGroups = true);
    try {
      final teacherService = ref.read(teacherServiceProvider);
      _groups = await teacherService.getGroups();
      if (_groups.isNotEmpty) {
        _selectedGroup = _groups.first;
        await _loadRewardsForGroup(_selectedGroup!.id);
      }
    } catch (e) {
      debugPrint('Error loading teacher data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingGroups = false);
    }
  }

  Future<void> _loadRewardsForGroup(String groupId) async {
    setState(() => _isLoadingRewards = true);
    try {
      final teacherService = ref.read(teacherServiceProvider);
      _teacherRewards = await teacherService.getRewards(groupId: groupId);
    } catch (e) {
      debugPrint('Error loading rewards: $e');
    } finally {
      if (mounted) setState(() => _isLoadingRewards = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _buildCustomAppBar(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Stars Balance
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF39C12), Color(0xFFD35400)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD35400).withValues(alpha: 0.3),
                      offset: const Offset(0, 8),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ESTRELLAS DISPONIBLES',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          prov.Consumer<GameState>(
                            builder: (context, gameState, child) {
                              final totalStars = widget.isTeacher ? 0 : gameState.totalStars;
                              return Row(
                                children: [
                                  Text(
                                    '$totalStars',
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.star, color: Colors.white, size: 36),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Cantidad de premios comprados (hide for teacher)
                    if (!widget.isTeacher)
                      prov.Consumer<GameState>(
                        builder: (context, gameState, _) {
                          final purchased = gameState.purchasedRewards;
                          if (purchased.isEmpty) return const SizedBox();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shopping_bag, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${purchased.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Group Selector for Teacher
            if (widget.isTeacher) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: AppColors.studentPrimary),
                    const SizedBox(width: 8),
                    const Text('Selecciona un grupo:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    if (_isLoadingGroups)
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    else if (_groups.isEmpty)
                      const Expanded(child: Text('No hay grupos', style: TextStyle(color: Colors.red)))
                    else
                      Expanded(
                        child: DropdownButton<GroupModel>(
                          isExpanded: true,
                          value: _selectedGroup,
                          items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedGroup = val);
                              _loadRewardsForGroup(val.id);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    '🎁 Premios Canjeables',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.isTeacher ? 'Premios disponibles para este grupo' : 'Gasta tus estrellas en premios especiales',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rewards Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: widget.isTeacher
                    ? _buildTeacherRewardsGrid()
                    : prov.Consumer<GameState>(
                        builder: (context, gameState, child) {
                          final rewards = gameState.rewards;
                          final totalStars = gameState.totalStars;
                          final purchased = gameState.purchasedRewards;

                          if (rewards.isEmpty) {
                            return _buildEmptyRewards();
                          }

                          return GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.55,
                            ),
                            itemCount: rewards.length,
                            itemBuilder: (context, index) {
                              final reward = rewards[index];
                              final bool isPurchased = purchased.contains(reward.id);
                              final bool isAffordable = totalStars >= reward.cost;

                              return _buildRewardCard(
                                context,
                                reward: reward,
                                isAffordable: isAffordable,
                                isPurchased: isPurchased,
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherRewardsGrid() {
    if (_isLoadingRewards) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_teacherRewards.isEmpty) {
      return _buildEmptyRewards();
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: _teacherRewards.length,
      itemBuilder: (context, index) {
        final r = _teacherRewards[index];
        final colorInt = _hexToColor(r.colorHex);
        final rewardData = RewardData(
          id: r.id,
          title: r.title,
          subtitle: r.subtitle,
          cost: r.cost,
          colorValue: colorInt,
          iconCodePoint: _getIconCodePoint(r.iconName),
        );
        // Cache the resolved icon for this reward
        _iconCache[r.iconName] = _getIcon(r.iconName);

        return _buildRewardCard(
          context,
          reward: rewardData,
          isAffordable: false, // Maestro no compra
          isPurchased: false,
        );
      },
    );
  }

  int _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.tryParse(hex, radix: 16) ?? 0xFF000000;
  }

  // Map of icon names to their constant IconData references
  final Map<String, IconData> _iconCache = {};

  int _getIconCodePoint(String iconName) {
    switch (iconName) {
      case 'star': return Icons.star.codePoint;
      case 'videogame_asset': return Icons.videogame_asset.codePoint;
      case 'color_lens': return Icons.color_lens.codePoint;
      case 'face': return Icons.face.codePoint;
      case 'lightbulb': return Icons.lightbulb.codePoint;
      case 'wallpaper': return Icons.wallpaper.codePoint;
      case 'crop_square': return Icons.crop_square.codePoint;
      default: return Icons.card_giftcard.codePoint;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'star': return Icons.star;
      case 'videogame_asset': return Icons.videogame_asset;
      case 'color_lens': return Icons.color_lens;
      case 'face': return Icons.face;
      case 'lightbulb': return Icons.lightbulb;
      case 'wallpaper': return Icons.wallpaper;
      case 'crop_square': return Icons.crop_square;
      default: return Icons.card_giftcard;
    }
  }

  IconData _getIconFromCodePoint(int codePoint) {
    // Check cache first
    for (final entry in _iconCache.entries) {
      if (entry.value.codePoint == codePoint) return entry.value;
    }
    // Fallback: match against known constant icons
    if (codePoint == Icons.star.codePoint) return Icons.star;
    if (codePoint == Icons.videogame_asset.codePoint) return Icons.videogame_asset;
    if (codePoint == Icons.color_lens.codePoint) return Icons.color_lens;
    if (codePoint == Icons.face.codePoint) return Icons.face;
    if (codePoint == Icons.lightbulb.codePoint) return Icons.lightbulb;
    if (codePoint == Icons.wallpaper.codePoint) return Icons.wallpaper;
    if (codePoint == Icons.crop_square.codePoint) return Icons.crop_square;
    return Icons.card_giftcard;
  }

  Widget _buildEmptyRewards() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.card_giftcard, size: 50, color: Color(0xFFF39C12)),
          const SizedBox(height: 16),
          Text(
            'No hay premios disponibles aún',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isTeacher ? 'Agrega premios en la Gestión de Premios' : 'Tu maestro agregará premios pronto',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(
    BuildContext context, {
    required RewardData reward,
    required bool isAffordable,
    required bool isPurchased,
  }) {
    final color = Color(reward.colorValue);
    final icon = _getIconFromCodePoint(reward.iconCodePoint);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPurchased
              ? const Color(0xFF27AE60)
              : isAffordable || widget.isTeacher
                  ? color.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
          width: isPurchased ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isPurchased
                ? const Color(0xFF27AE60).withValues(alpha: 0.15)
                : isAffordable || widget.isTeacher
                    ? color.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isPurchased
                    ? const Color(0xFFD5F5E3)
                    : isAffordable || widget.isTeacher
                        ? color.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 60,
                    color: isPurchased
                        ? const Color(0xFF27AE60)
                        : isAffordable || widget.isTeacher
                            ? color
                            : Colors.grey.shade400,
                  ),
                  if (isPurchased)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF27AE60),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isPurchased ? const Color(0xFF27AE60) : ((isAffordable || widget.isTeacher) ? AppColors.textDark : Colors.grey),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reward.subtitle,
                  style: TextStyle(
                    color: isPurchased ? const Color(0xFF27AE60) : ((isAffordable || widget.isTeacher) ? color : Colors.grey),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: isPurchased
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD5F5E3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 18),
                              SizedBox(width: 6),
                              Text(
                                '¡Canjeado!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF27AE60),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: (isAffordable && !widget.isTeacher)
                              ? () => _showPurchaseDialog(context, reward)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (isAffordable || widget.isTeacher) ? const Color(0xFFF39C12) : Colors.grey.shade300,
                            foregroundColor: (isAffordable || widget.isTeacher) ? Colors.white : Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${reward.cost}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, RewardData reward) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFDF8F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Color(reward.colorValue).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getIconFromCodePoint(reward.iconCodePoint),
                  size: 36,
                  color: Color(reward.colorValue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Canjear ${reward.title}?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4A3423),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Color(0xFFF39C12), size: 22),
                const SizedBox(width: 4),
                Text(
                  '${reward.cost} estrellas',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF39C12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF4A3423), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A3423)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await context.read<GameState>().spendStars(reward.id, reward.cost);
                      if (!context.mounted) return;
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(success ? Icons.check_circle : Icons.cancel, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  success
                                      ? '¡${reward.title} canjeado con éxito!'
                                      : 'No se pudo canjear',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: success ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF39C12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '¡Canjear!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.studentBorder,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
          Text(
            'EcoQuiz',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.studentBorder,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.studentBorder),
              onPressed: () => SettingsBottomSheet.show(context),
            ),
          ),
        ],
      ),
    );
  }
}
