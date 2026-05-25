import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../../domain/models/game_state.dart';
import '../widgets/settings_bottom_sheet.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _ranking = [];

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    try {
      final gameState = Provider.of<GameState>(context, listen: false);
      final groupCode = gameState.playerGroup;
      final playerName = gameState.playerName;
      final client = Supabase.instance.client;

      final groupResult = await client
          .from('groups')
          .select('id')
          .eq('code', groupCode)
          .maybeSingle();

      if (groupResult == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final groupId = groupResult['id'];

      final members = await client
          .from('group_members')
          .select('student_id, profiles!inner(name, created_at)')
          .eq('group_id', groupId);

      // Calcular el inicio de la semana actual (Lunes a las 00:00:00)
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeek = DateTime(monday.year, monday.month, monday.day);

      // Buscar registros de actividad solo de esta semana
      final activityLogs = await client
          .from('activity_log')
          .select('student_id, stars_added')
          .gte('created_at', startOfWeek.toIso8601String());

      List<Map<String, dynamic>> newRanking = [];

      for (final m in members) {
        final sId = m['student_id'];
        final name = m['profiles']['name'] as String;

        // Sumar solo las estrellas ganadas ESTA semana (ignorando compras)
        int weeklyStars = 0;
        for (final log in activityLogs) {
          if (log['student_id'] == sId) {
            weeklyStars += (log['stars_added'] as int);
          }
        }

        newRanking.add({
          'name': name,
          'stars': weeklyStars,
          'isCurrentUser': name == playerName,
        });
      }

      newRanking.sort((a, b) => (b['stars'] as int).compareTo(a['stars'] as int));

      final colors = [
        const Color(0xFF005A9C),
        const Color(0xFF27AE60),
        const Color(0xFFE74C3C),
        const Color(0xFF8E44AD),
      ];

      for (int i = 0; i < newRanking.length; i++) {
        final isMe = newRanking[i]['isCurrentUser'] as bool;
        newRanking[i]['progressColor'] = isMe ? const Color(0xFFF39C12) : colors[i % colors.length];
        newRanking[i]['avatarColor'] = isMe ? Colors.orange.shade200 : colors[i % colors.length].withValues(alpha: 0.3);
      }

      if (mounted) {
        setState(() {
          _ranking = newRanking;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching ranking: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              
              // 2. Título del Ranking Dinámico
              Builder(
                builder: (context) {
                  final now = DateTime.now();
                  final monday = now.subtract(Duration(days: now.weekday - 1));
                  final sunday = monday.add(const Duration(days: 6));
                  final formattedMonday = "${monday.day.toString().padLeft(2, '0')}/${monday.month.toString().padLeft(2, '0')}";
                  final formattedSunday = "${sunday.day.toString().padLeft(2, '0')}/${sunday.month.toString().padLeft(2, '0')}";
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ranking Semanal ($formattedMonday - $formattedSunday)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textDark,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mira el progreso de tus compañeros durante esta semana.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  );
                }
              ),
              
              const SizedBox(height: 24),
              
              // 3. Lista de Ranking
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF27AE60)))
                  : _ranking.isEmpty
                      ? const Center(child: Text('Aún no hay progreso en el grupo.'))
                      : Column(
                          children: _ranking.map((s) {
                            // Calcular progreso falso basado en estrellas (max 40)
                            final progress = (s['stars'] as int) / 40.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildRankingCard(
                                name: s['name'] as String,
                                stars: s['stars'] as int,
                                progress: progress.clamp(0.0, 1.0),
                                progressColor: s['progressColor'] as Color,
                                avatarColor: s['avatarColor'] as Color,
                                isCurrentUser: s['isCurrentUser'] as bool,
                              ),
                            );
                          }).toList(),
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

  Widget _buildStudentInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.studentPrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.studentPrimary.withValues(alpha: 0.2),
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
                Consumer<GameState>(
                  builder: (context, gameState, _) => Text(
                    gameState.playerName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textBrown,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.studentPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Consumer<GameState>(
                    builder: (context, gameState, _) => Text(
                      'Grupo: ${gameState.playerGroup}',
                      style: const TextStyle(
                        color: AppColors.studentBorder,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
        color: isCurrentUser ? progressColor.withValues(alpha: 0.05) : Colors.white,
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
              onPressed: () => SettingsBottomSheet.show(context),
            ),
          ),
        ],
      ),
    );
  }
}
