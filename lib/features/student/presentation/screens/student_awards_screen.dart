import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
                        Text(
                          '18',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
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
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                  children: [
                    _buildRewardCard(
                      context,
                      title: 'Avatar Especial',
                      subtitle: 'Ocelote',
                      cost: 50,
                      icon: Icons.face,
                      color: const Color(0xFF8E44AD),
                      isAffordable: false,
                    ),
                    _buildRewardCard(
                      context,
                      title: 'Pista Extra',
                      subtitle: 'Para el Quiz',
                      cost: 10,
                      icon: Icons.lightbulb_outline,
                      color: const Color(0xFFF1C40F),
                      isAffordable: true,
                    ),
                    _buildRewardCard(
                      context,
                      title: 'Fondo Animado',
                      subtitle: 'Desierto',
                      cost: 100,
                      icon: Icons.wallpaper,
                      color: const Color(0xFF27AE60),
                      isAffordable: false,
                    ),
                    _buildRewardCard(
                      context,
                      title: 'Marco de Oro',
                      subtitle: 'Para tu Perfil',
                      cost: 200,
                      icon: Icons.crop_square,
                      color: const Color(0xFFE67E22),
                      isAffordable: false,
                    ),
                  ],
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
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon Banner
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Center(
                child: Icon(icon, size: 60, color: color),
              ),
            ),
          ),
          
          // Details
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  // Cost Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: const Color(0xFFF39C12), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$cost',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isAffordable ? const Color(0xFFD35400) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Redeem Button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: isAffordable ? () {} : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAffordable ? AppColors.studentPrimary : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Canjear',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAffordable ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
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
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
