import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../student/domain/models/game_state.dart';

class TeacherProgressScreen extends StatelessWidget {
  const TeacherProgressScreen({super.key});

  // Mock biome data: avg stars per biome (0-3)
  static const List<_BiomeData> _biomeData = [
    _BiomeData('Ciudad', 0, Color(0xFFFFDAB9), 2.8),
    _BiomeData('Manglar', 1, Color(0xFFFFD1DC), 1.5),
    _BiomeData('Arrecife', 2, Color(0xFFD6EAF8), 2.1),
    _BiomeData('Bosque', 3, Color(0xFF98FB98), 0.9),
    _BiomeData('Selva', 4, Color(0xFF5ABF5A), 1.2),
    _BiomeData('Desierto', 5, Color(0xFFFDE8E1), 0.3),
  ];

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
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Semana 3 — Actividad',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textBrown,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Desempeño promedio de los estudiantes por bioma.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              // Summary stat cards
              Row(
                children: [
                  _buildStatPill(
                    icon: Icons.people_alt,
                    label: 'Alumnos',
                    value: '28',
                    color: const Color(0xFF27AE60),
                    bgColor: const Color(0xFFD5F5E3),
                  ),
                  const SizedBox(width: 12),
                  _buildStatPill(
                    icon: Icons.star,
                    label: 'Promedio',
                    value: '20.2 ⭐',
                    color: const Color(0xFFF39C12),
                    bgColor: const Color(0xFFFEF9E7),
                  ),
                  const SizedBox(width: 12),
                  ValueListenableBuilder<List<bool>>(
                    valueListenable: GameState.instance.unlockedLevels,
                    builder: (context, levels, _) {
                      final unlocked = levels.where((b) => b).length;
                      return _buildStatPill(
                        icon: Icons.lock_open,
                        label: 'Niveles',
                        value: '$unlocked / 6',
                        color: const Color(0xFF2B9BF4),
                        bgColor: const Color(0xFFD6EAF8),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Bar Chart Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⭐ Estrellas Promedio por Bioma',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Máximo posible: 3 estrellas',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          maxY: 3,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppColors.textBrown,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${_biomeData[groupIndex].label}\n${rod.toY.toStringAsFixed(1)} ⭐',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= _biomeData.length) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      _biomeData[i].label,
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(_biomeData.length, (i) {
                            final d = _biomeData[i];
                            Color barColor;
                            if (d.avgStars >= 2.5) barColor = const Color(0xFF27AE60);
                            else if (d.avgStars >= 1.5) barColor = const Color(0xFFF39C12);
                            else barColor = const Color(0xFFE74C3C);

                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: d.avgStars,
                                  color: barColor,
                                  width: 28,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: 3,
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Biome Breakdown List
              Text(
                'Detalle por bioma',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBrown,
                ),
              ),
              const SizedBox(height: 12),
              ..._biomeData.map((d) => _buildBiomeRow(d)),

              const SizedBox(height: 28),

              // Student Ranking
              Text(
                'Ranking de alumnos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBrown,
                ),
              ),
              const SizedBox(height: 12),
              _buildRankingCard(rank: 1, name: 'Sofía Ramírez', stars: 30, progress: 0.9, color: const Color(0xFF27AE60)),
              const SizedBox(height: 10),
              _buildRankingCard(rank: 2, name: 'Ana López', stars: 24, progress: 0.8, color: const Color(0xFFF39C12)),
              const SizedBox(height: 10),
              _buildRankingCard(rank: 3, name: 'Juan Pérez', stars: 18, progress: 0.6, color: const Color(0xFF2B9BF4)),
              const SizedBox(height: 10),
              _buildRankingCard(rank: 4, name: 'Carlos Méndez', stars: 9, progress: 0.3, color: const Color(0xFFE74C3C)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textDark)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildBiomeRow(_BiomeData d) {
    Color trackColor;
    if (d.avgStars >= 2.5) trackColor = const Color(0xFF27AE60);
    else if (d.avgStars >= 1.5) trackColor = const Color(0xFFF39C12);
    else trackColor = const Color(0xFFE74C3C);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: d.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: d.avgStars / 3.0,
                      backgroundColor: Colors.white.withOpacity(0.7),
                      valueColor: AlwaysStoppedAnimation<Color>(trackColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${d.avgStars.toStringAsFixed(1)} ⭐',
              style: TextStyle(fontWeight: FontWeight.w900, color: trackColor, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard({
    required int rank,
    required String name,
    required int stars,
    required double progress,
    required Color color,
  }) {
    final medalColors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
    final medal = rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '$rank';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rank <= 3 ? medalColors[rank - 1].withOpacity(0.2) : Colors.grey.shade100,
            ),
            child: Center(
              child: Text(medal, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Icon(Icons.star, color: const Color(0xFFF39C12), size: 18),
              const SizedBox(width: 4),
              Text('$stars', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textDark)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BiomeData {
  final String label;
  final int mapIndex;
  final Color color;
  final double avgStars;

  const _BiomeData(this.label, this.mapIndex, this.color, this.avgStars);
}
