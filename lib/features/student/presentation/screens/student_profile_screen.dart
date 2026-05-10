import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5), // Light warm background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _buildCustomAppBar(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tarjeta de Información del Alumno
              _buildStudentInfoCard(context),
              
              const SizedBox(height: 32),
              
              // 2. Título del Ranking
              Text(
                'Ranking del Grupo — Semana 3',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textDark,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mira cómo van tus compañeros en la expedición educativa.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              
              const SizedBox(height: 24),
              
              // 3. Lista de Ranking
              _buildRankingCard(
                name: 'Sofía Ramírez',
                stars: 30,
                progress: 0.8,
                progressColor: const Color(0xFF005A9C), // Dark blue
                avatarColor: Colors.blue.shade200,
                isCurrentUser: false,
              ),
              const SizedBox(height: 12),
              _buildRankingCard(
                name: 'Ana López',
                stars: 24,
                progress: 0.6,
                progressColor: const Color(0xFF27AE60), // Green
                avatarColor: Colors.green.shade200,
                isCurrentUser: false,
              ),
              const SizedBox(height: 12),
              _buildRankingCard(
                name: 'Juan Pérez',
                stars: 18,
                progress: 0.45,
                progressColor: const Color(0xFFF39C12), // Orange
                avatarColor: Colors.orange.shade200,
                isCurrentUser: true, // Assuming this is the current student
              ),
              const SizedBox(height: 12),
              _buildRankingCard(
                name: 'Carlos Méndez',
                stars: 9,
                progress: 0.2,
                progressColor: const Color(0xFFE74C3C), // Red
                avatarColor: Colors.red.shade200,
                isCurrentUser: false,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.studentPrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.studentPrimary.withOpacity(0.2),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.studentPrimary, width: 3),
            ),
            child: const Center(
              child: Icon(Icons.face, size: 40, color: Color(0xFFE67E22)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juan Pérez',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textBrown,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.studentPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Grupo: 4B',
                    style: TextStyle(
                      color: AppColors.studentBorder,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildRankingCard({
    required String name,
    required int stars,
    required double progress,
    required Color progressColor,
    required Color avatarColor,
    required bool isCurrentUser,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? progressColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrentUser ? progressColor : Colors.grey.shade300,
          width: isCurrentUser ? 3 : 2,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: Icon(Icons.person, color: Colors.black54),
          ),
          const SizedBox(width: 16),
          // Name & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    // Star Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E1), // Light pink/orange
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_border, color: Color(0xFFE67E22), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '$stars',
                            style: const TextStyle(
                              color: Color(0xFFE67E22),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Custom Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 12,
                    child: Stack(
                      children: [
                        Container(color: const Color(0xFFFDE8E1)), // Track color
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: progressColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
