import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'teacher_profile_screen.dart';
// Note: For now, reusing student screens for Map, Journal, Awards to demonstrate shell
import '../../../student/presentation/screens/student_map_screen.dart';
import '../../../student/presentation/screens/student_journal_screen.dart';
import '../../../student/presentation/screens/student_awards_screen.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _currentIndex = 3; // Start on Profile/Dashboard

  // In a real app, Map, Journal, and Awards might be slightly different for teachers
  // but we reuse the student ones here as placeholders to complete the shell.
  final List<Widget> _screens = [
    const StudentMapScreen(isTeacher: true),
    const StudentJournalScreen(),
    const StudentAwardsScreen(isTeacher: true),
    const TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, 'Map', Icons.map_outlined),
                _buildNavItem(1, 'Journal', Icons.menu_book),
                _buildNavItem(2, 'Awards', Icons.stars),
                _buildNavItem(3, 'Profile', Icons.person_outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.studentPrimary.withValues(alpha: 0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.studentBorder : Colors.grey.shade500,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? AppColors.studentBorder : Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
