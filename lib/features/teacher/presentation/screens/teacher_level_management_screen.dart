import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TeacherLevelManagementScreen extends StatefulWidget {
  const TeacherLevelManagementScreen({super.key});

  @override
  State<TeacherLevelManagementScreen> createState() => _TeacherLevelManagementScreenState();
}

class _TeacherLevelManagementScreenState extends State<TeacherLevelManagementScreen> {
  // Track expanded state for 6 zones
  final List<bool> _zoneExpanded = [true, false, false, false, false, false];

  // Mock state for switches [zoneIndex_levelIndex]
  final Map<String, bool> _levelStates = {
    '0_0': true, '0_1': true, '0_2': false,
    '1_0': false, '1_1': false, '1_2': false,
    '2_0': false, '2_1': false, '2_2': false,
    '3_0': false, '3_1': false, '3_2': false,
    '4_0': false, '4_1': false, '4_2': false,
    '5_0': false, '5_1': false, '5_2': false,
  };

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
          'Configuración',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF1E5B1E), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de\nNiveles',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textBrown,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Controla el acceso a las diferentes zonas y niveles para tus alumnos.',
                      style: TextStyle(
                        color: AppColors.textDark.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF39C12), // Orange button
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD35400), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD35400).withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppColors.textBrown, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Sugerencia semanal de desbloqueo',
                            style: TextStyle(
                              color: AppColors.textBrown,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Zones
              _buildZoneCard(0, 'Zona 1: Desierto\nde Sonora', Icons.park, const Color(0xFF5ABF5A), [
                'Conoce a la Tortuga del\nDesierto',
                'Supervivencia sin agua',
                'Quiz: Cactus Gigantes'
              ]),
              const SizedBox(height: 16),
              _buildZoneCard(1, 'Zona 2: Selva de\nChiapas', Icons.eco, const Color(0xFFFDE8E1), [
                'El reino del Jaguar',
                'Plantas medicinales',
                'Misión: Reforestación'
              ]),
              const SizedBox(height: 16),
              _buildZoneCard(2, 'Zona 3: Arrecife', Icons.water, const Color(0xFFD6EAF8), [
                'Corales de colores',
                'Peces asombrosos',
                'Limpieza del océano'
              ]),
              const SizedBox(height: 16),
              _buildZoneCard(3, 'Zona 4: Bosque', Icons.emoji_nature, const Color(0xFF98FB98), [
                'Mariposa Monarca',
                'Árboles ancestrales',
                'Quiz: Flora del bosque'
              ]),
              const SizedBox(height: 16),
              _buildZoneCard(4, 'Zona 5: Manglar', Icons.filter_vintage, const Color(0xFFFFD1DC), [
                'Raíces en el agua',
                'Fauna escondida',
                'Protege el manglar'
              ]),
              const SizedBox(height: 16),
              _buildZoneCard(5, 'Zona 6: Ciudad', Icons.location_city, const Color(0xFFFFDAB9), [
                'Contaminación del aire',
                'Reciclaje urbano',
                'Crea tu huerto'
              ]),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneCard(int zoneIndex, String title, IconData icon, Color headerColor, List<String> levelTitles) {
    final isExpanded = _zoneExpanded[zoneIndex];
    // Consider a zone unlocked if at least one level is enabled
    final isUnlocked = _levelStates['${zoneIndex}_0']! || _levelStates['${zoneIndex}_1']! || _levelStates['${zoneIndex}_2']!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _zoneExpanded[zoneIndex] = !_zoneExpanded[zoneIndex];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.white : headerColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: isExpanded 
                    ? const BorderRadius.vertical(top: Radius.circular(30)) 
                    : BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.textDark, width: 1.5),
                    ),
                    child: Icon(icon, color: AppColors.textDark, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                            height: 1.1,
                          ),
                        ),
                        if (isExpanded || !isUnlocked) const SizedBox(height: 6),
                        if (isExpanded)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isUnlocked ? const Color(0xFF1E5B1E) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isUnlocked ? null : Border.all(color: AppColors.textDark),
                            ),
                            child: Text(
                              isUnlocked ? 'DESBLOQUEADA' : 'BLOQUEADA',
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : AppColors.textDark,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                        else if (!isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade500),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'BLOQUEADA',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textDark,
                    size: 28,
                  ),
                ],
              ),
            ),
            // Body (Levels) - Only visible when expanded
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildLevelItem(
                            number: '1',
                            title: levelTitles[0],
                            isEnabled: _levelStates['${zoneIndex}_0']!,
                            onChanged: (val) => setState(() => _levelStates['${zoneIndex}_0'] = val),
                          ),
                          _buildDivider(),
                          _buildLevelItem(
                            number: '2',
                            title: levelTitles[1],
                            isEnabled: _levelStates['${zoneIndex}_1']!,
                            onChanged: (val) => setState(() => _levelStates['${zoneIndex}_1'] = val),
                          ),
                          _buildDivider(),
                          _buildLevelItem(
                            number: '3',
                            title: levelTitles[2],
                            isEnabled: _levelStates['${zoneIndex}_2']!,
                            onChanged: (val) => setState(() => _levelStates['${zoneIndex}_2'] = val),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelItem({
    required String number,
    required String title,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF4FA0F6), // Blue circle
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textDark, width: 1),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.2,
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF1E5B1E), // Dark green
            inactiveThumbColor: Colors.grey.shade500,
            inactiveTrackColor: const Color(0xFFFDE8E1),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: Colors.grey.shade300, thickness: 1.5),
    );
  }
}
