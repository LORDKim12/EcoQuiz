import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TeacherProgressScreen extends StatelessWidget {
  const TeacherProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Progreso del Grupo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progreso del Grupo — Semana 3',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textDark,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitorea el avance de tus estudiantes en su expedición educativa.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),

              // Ranking List
              _buildRankingCard(
                name: 'Ana López',
                stars: 24,
                progress: 0.8,
                progressColor: const Color(0xFF27AE60),
                avatarColor: Colors.green.shade200,
              ),
              const SizedBox(height: 12),
              _buildRankingCard(
                name: 'Juan Pérez',
                stars: 18,
                progress: 0.6,
                progressColor: const Color(0xFFF39C12),
                avatarColor: Colors.orange.shade200,
              ),
              const SizedBox(height: 12),
              _buildRankingCard(
                name: 'Sofía Ramírez',
                stars: 30,
                progress: 0.9,
                progressColor: const Color(0xFF005A9C),
                avatarColor: Colors.blue.shade200,
              ),
              const SizedBox(height: 12),
              _buildRankingCard(
                name: 'Carlos Méndez',
                stars: 9,
                progress: 0.3,
                progressColor: const Color(0xFFE74C3C),
                avatarColor: Colors.red.shade200,
              ),

              const SizedBox(height: 32),

              // Group Stats
              _buildGroupStatsCard(context),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingCard({
    required String name,
    required int stars,
    required double progress,
    required Color progressColor,
    required Color avatarColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: const Icon(Icons.person, color: Colors.black54),
          ),
          const SizedBox(width: 16),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E1),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 12,
                    child: Stack(
                      children: [
                        Container(color: const Color(0xFFFDE8E1)),
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

  Widget _buildGroupStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EBFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF85C1E9), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas del Grupo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF2C3E50),
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  icon: Icons.people_alt,
                  value: '4',
                  label: 'Alumnos',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  icon: Icons.star_border,
                  value: '81',
                  label: 'Estrellas Totales',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.trending_up, color: Color(0xFF27AE60), size: 28),
                const SizedBox(height: 4),
                const Text(
                  'Alto',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Nivel de Participación',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Color(0xFF27AE60)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡El grupo está avanzando súper bien esta semana! Sofía lidera la expedición.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
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

  Widget _buildStatBox({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2980B9), size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
