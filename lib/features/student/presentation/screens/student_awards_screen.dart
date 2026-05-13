import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/game_state.dart';

class StudentAwardsScreen extends StatelessWidget {
  const StudentAwardsScreen({super.key});

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
                      color: const Color(0xFFD35400).withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Column(
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
                        ValueListenableBuilder<int>(
                          valueListenable: GameState.instance.totalStars,
                          builder: (context, totalStars, child) {
                            return Text(
                              '$totalStars',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Premios Canjeables',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rewards Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ValueListenableBuilder<List<RewardData>>(
                  valueListenable: GameState.instance.rewards,
                  builder: (context, rewards, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: GameState.instance.totalStars,
                      builder: (context, totalStars, child) {
                        if (rewards.isEmpty) {
                          return const Center(child: Text('No hay premios disponibles aún.'));
                        }

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.55,
                          ),
                          itemCount: rewards.length,
                          itemBuilder: (context, index) {
                            final reward = rewards[index];
                            final bool isAffordable = totalStars >= reward.cost;

                            return _buildRewardCard(
                              context,
                              title: reward.title,
                              subtitle: reward.subtitle,
                              cost: reward.cost,
                              icon: IconData(reward.iconCodePoint, fontFamily: 'MaterialIcons'),
                              color: Color(reward.colorValue),
                              isAffordable: isAffordable,
                            );
                          },
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

  Widget _buildRewardCard(BuildContext context, {
    required String title,
    required String subtitle,
    required int cost,
    required IconData icon,
    required Color color,
    required bool isAffordable,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAffordable ? color.withOpacity(0.3) : Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: isAffordable ? color.withOpacity(0.1) : Colors.black.withOpacity(0.05),
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
                color: isAffordable ? color.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 60,
                  color: isAffordable ? color : Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isAffordable ? AppColors.textDark : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isAffordable ? color : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isAffordable ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('¡Compraste $title! (Simulación)')),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAffordable ? const Color(0xFFF39C12) : Colors.grey.shade300,
                      foregroundColor: isAffordable ? Colors.white : Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                          '$cost',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withOpacity(0.95),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
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
        ],
      ),
    );
  }
}
