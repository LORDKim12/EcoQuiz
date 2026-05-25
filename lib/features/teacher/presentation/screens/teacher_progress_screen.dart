import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/models/models.dart';

class TeacherProgressScreen extends ConsumerStatefulWidget {
  const TeacherProgressScreen({super.key});

  @override
  ConsumerState<TeacherProgressScreen> createState() => _TeacherProgressScreenState();
}

class _TeacherProgressScreenState extends ConsumerState<TeacherProgressScreen> {
  bool _isLoading = true;
  List<GroupModel> _groups = [];
  GroupModel? _selectedGroup;
  int _studentCount = 0;
  int _activeLevelsCount = 0;
  double _overallAverage = 0.0;
  List<_BiomeData> _biomeData = [];
  List<Map<String, dynamic>> _ranking = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final teacherService = ref.read(teacherServiceProvider);
      
      if (_groups.isEmpty) {
        _groups = await teacherService.getGroups();
        if (_groups.isNotEmpty) {
          _selectedGroup = _groups.first;
        }
      }
      
      if (_selectedGroup != null) {
        final stats = await teacherService.getGroupStats(_selectedGroup!.id);

        final List<dynamic> biomesRaw = stats['biomeAverages'];
        final biomes = biomesRaw.map((b) {
          final biomeKey = b['biome'] as String;
          return _BiomeData(
            b['label'],
            _getColorForBiome(biomeKey),
            (b['avgStars'] as num).toDouble(),
          );
        }).toList();

        if (mounted) {
          setState(() {
            _studentCount = stats['studentCount'] as int;
            _activeLevelsCount = stats['activeLevelsCount'] as int;
            _overallAverage = (stats['overallAverage'] as num).toDouble();
            _biomeData = biomes;
            _ranking = List<Map<String, dynamic>>.from(stats['ranking']);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getColorForBiome(String biome) {
    switch (biome.toLowerCase()) {
      case 'ciudad': return const Color(0xFFFFDAB9);
      case 'manglar': return const Color(0xFFFFD1DC);
      case 'arrecife': return const Color(0xFFD6EAF8);
      case 'bosque': return const Color(0xFF98FB98);
      case 'selva': return const Color(0xFF5ABF5A);
      case 'desierto': return const Color(0xFFFDE8E1);
      default: return const Color(0xFFE5E7EB);
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Esta Semana — Actividad',
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

                    // Group Selector
                    if (_groups.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.group, color: AppColors.studentPrimary),
                          const SizedBox(width: 8),
                          const Text('Selecciona un grupo:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButton<GroupModel>(
                              isExpanded: true,
                              value: _selectedGroup,
                              items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedGroup = val);
                                  _loadStats();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Summary stat cards
                    Row(
                      children: [
                        _buildStatPill(
                          icon: Icons.people_alt,
                          label: 'Alumnos',
                          value: '$_studentCount',
                          color: const Color(0xFF27AE60),
                          bgColor: const Color(0xFFD5F5E3),
                        ),
                        const SizedBox(width: 12),
                        _buildStatPill(
                          icon: Icons.star,
                          label: 'Promedio',
                          value: '${_overallAverage.toStringAsFixed(1)} pts',
                          color: const Color(0xFFF39C12),
                          bgColor: const Color(0xFFFEF9E7),
                        ),
                        const SizedBox(width: 12),
                        _buildStatPill(
                          icon: Icons.lock_open,
                          label: 'Niveles',
                          value: '$_activeLevelsCount',
                          color: const Color(0xFF2B9BF4),
                          bgColor: const Color(0xFFD6EAF8),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Bar Chart Card (only if we have data)
                    if (_biomeData.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estrellas Promedio por Bioma',
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
                                          '${_biomeData[groupIndex].label}\n${rod.toY.toStringAsFixed(1)} pts',
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
                                    if (d.avgStars >= 2.5) {
                                      barColor = const Color(0xFF27AE60);
                                    } else if (d.avgStars >= 1.5) {
                                      barColor = const Color(0xFFF39C12);
                                    } else {
                                      barColor = const Color(0xFFE74C3C);
                                    }

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
                    if (_biomeData.isNotEmpty) ...[
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
                    ],

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
                    if (_ranking.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('No hay alumnos registrados o activos.'),
                        ),
                      )
                    else
                      ...List.generate(_ranking.length, (index) {
                        final student = _ranking[index];
                        final rank = index + 1;
                        
                        // Determinar color y progreso de la barra visual
                        Color trackColor;
                        if (rank == 1) {
                          trackColor = const Color(0xFF27AE60);
                        } else if (rank == 2) {
                          trackColor = const Color(0xFFF39C12);
                        } else if (rank == 3) {
                          trackColor = const Color(0xFF2B9BF4);
                        } else {
                          trackColor = const Color(0xFFE74C3C);
                        }
                        
                        // Progreso simulado basado en la estrella máxima para visual (opcional)
                        double maxStars = (_ranking.isNotEmpty) ? _ranking.first['stars'] * 1.0 : 1.0;
                        if (maxStars == 0) maxStars = 1.0;
                        double progress = student['stars'] / maxStars;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildRankingCard(
                            rank: rank,
                            name: student['name'],
                            stars: student['stars'],
                            progress: progress,
                            color: trackColor,
                          ),
                        );
                      }),

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
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
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
    if (d.avgStars >= 2.5) {
      trackColor = const Color(0xFF27AE60);
    } else if (d.avgStars >= 1.5) {
      trackColor = const Color(0xFFF39C12);
    } else {
      trackColor = const Color(0xFFE74C3C);
    }

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
                      backgroundColor: Colors.white.withValues(alpha: 0.7),
                      valueColor: AlwaysStoppedAnimation<Color>(trackColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${d.avgStars.toStringAsFixed(1)} pts',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rank == 1 ? Colors.yellow.shade700 : (rank == 2 ? Colors.grey.shade400 : (rank == 3 ? Colors.brown.shade400 : Colors.blue.shade100)),
            child: Text('$rank', style: TextStyle(color: rank <= 3 ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
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
  final Color color;
  final double avgStars;

  const _BiomeData(this.label, this.color, this.avgStars);
}
