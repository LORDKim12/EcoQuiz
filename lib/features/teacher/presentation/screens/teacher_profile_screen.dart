import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'teacher_progress_screen.dart';
import 'teacher_level_management_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

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
              Text(
                '¡Hola, Maestra\nGarcía!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textBrown,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí está el resumen de la aventura de hoy.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Stat Cards
              _buildStatCard(
                icon: Icons.people_alt,
                label: 'ALUMNOS ACTIVOS',
                value: '28',
                bgColor: const Color(0xFFFDE8E1),
                iconBgColor: Colors.white,
                iconColor: const Color(0xFF27AE60),
                textColor: AppColors.textBrown,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                icon: Icons.calendar_today,
                label: 'SEMANA ACTUAL',
                value: '3',
                bgColor: const Color(0xFFF39C12),
                iconBgColor: Colors.white,
                iconColor: const Color(0xFFD35400),
                textColor: AppColors.textBrown,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                icon: Icons.star_border,
                label: 'PROMEDIO DEL GRUPO',
                value: '20.2',
                valueIcon: Icons.star,
                valueIconColor: const Color(0xFFF1C40F),
                bgColor: const Color(0xFF3498DB),
                iconBgColor: Colors.white,
                iconColor: const Color(0xFF2980B9),
                textColor: AppColors.textDark,
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButton(
                label: 'Ver Progreso',
                icon: Icons.bar_chart,
                bgColor: const Color(0xFFFFDAB9), // Peach color
                textColor: AppColors.textDark,
                iconBgColor: Colors.black.withOpacity(0.05),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherProgressScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                label: 'Configurar Grupo',
                icon: Icons.group_add,
                bgColor: const Color(0xFFD6EAF8), // Light blue
                textColor: AppColors.textDark,
                iconBgColor: Colors.black.withOpacity(0.05),
                onTap: () {},
              ),
              const SizedBox(height: 32),
              
              // Botón de Cerrar Sesión
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color iconBgColor,
    required Color iconColor,
    required Color textColor,
    IconData? valueIcon,
    Color? valueIconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (valueIcon != null) ...[
                Icon(valueIcon, color: valueIconColor, size: 36),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: textColor, size: 28),
          ],
        ),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeacherLevelManagementScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
