import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../student/domain/models/game_state.dart';
import 'teacher_question_management_screen.dart';

// ── Mapa de colores e iconos por bioma ─────────────────────────────
class _BiomeTheme {
  final Color primary;
  final Color secondary;
  final IconData icon;
  final String emoji;

  const _BiomeTheme({
    required this.primary,
    required this.secondary,
    required this.icon,
    required this.emoji,
  });
}

final Map<String, _BiomeTheme> _biomeThemes = {
  'ciudad': const _BiomeTheme(
    primary: Color(0xFF546E7A),
    secondary: Color(0xFF90A4AE),
    icon: Icons.location_city,
    emoji: '🏙️',
  ),
  'manglar': const _BiomeTheme(
    primary: Color(0xFF2E7D32),
    secondary: Color(0xFF81C784),
    icon: Icons.water,
    emoji: '🌿',
  ),
  'arrecife': const _BiomeTheme(
    primary: Color(0xFF0277BD),
    secondary: Color(0xFF4FC3F7),
    icon: Icons.waves,
    emoji: '🐠',
  ),
  'bosque': const _BiomeTheme(
    primary: Color(0xFF33691E),
    secondary: Color(0xFFA5D6A7),
    icon: Icons.forest,
    emoji: '🌲',
  ),
  'selva': const _BiomeTheme(
    primary: Color(0xFF1B5E20),
    secondary: Color(0xFF66BB6A),
    icon: Icons.eco,
    emoji: '🦜',
  ),
  'desierto': const _BiomeTheme(
    primary: Color(0xFFE65100),
    secondary: Color(0xFFFFCC80),
    icon: Icons.wb_sunny,
    emoji: '🏜️',
  ),
  'tundra': const _BiomeTheme(
    primary: Color(0xFF4DD0E1),
    secondary: Color(0xFFB2EBF2),
    icon: Icons.ac_unit,
    emoji: '❄️',
  ),
};

_BiomeTheme _getTheme(String biome) {
  final lower = biome.toLowerCase();
  for (final key in _biomeThemes.keys) {
    if (lower.contains(key)) return _biomeThemes[key]!;
  }
  // Fallback: un tema genérico bonito
  return const _BiomeTheme(
    primary: Color(0xFF7E57C2),
    secondary: Color(0xFFB39DDB),
    icon: Icons.public,
    emoji: '🌍',
  );
}

// ── Pantalla principal ─────────────────────────────────────────────
class TeacherLevelManagementScreen extends StatefulWidget {
  const TeacherLevelManagementScreen({super.key});

  @override
  State<TeacherLevelManagementScreen> createState() => _TeacherLevelManagementScreenState();
}

class _TeacherLevelManagementScreenState extends State<TeacherLevelManagementScreen> {

  // ── Crear nuevo bioma ───────────────────────────────────────────
  void _showAddBiomeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2B9BF4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.public, color: Color(0xFF2B9BF4), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Nuevo Mundo',
                style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textBrown)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crea un nuevo bioma/mundo para organizar tus niveles.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Ej. Tundra, Volcán, Sabana…',
                prefixIcon: const Icon(Icons.terrain, color: Color(0xFF2B9BF4)),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2B9BF4), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              // Verificar que no exista ya
              final existing = GameState.instance.levels.value.map((l) => l.biome.toLowerCase()).toSet();
              if (existing.contains(name.toLowerCase())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('El bioma "$name" ya existe'), backgroundColor: Colors.orange),
                );
                return;
              }
              GameState.instance.addLevel('Nivel 1', biome: name);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Bioma "$name" creado con Nivel 1'),
                  ]),
                  backgroundColor: const Color(0xFF27AE60),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Crear', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B9BF4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Agregar nivel a un bioma ─────────────────────────────────────
  void _showAddLevelDialog(String biome) {
    final controller = TextEditingController();
    final theme = _getTheme(biome);
    // Contar niveles existentes para sugerir nombre
    final existingCount = GameState.instance.levels.value.where((l) => l.biome == biome).length;
    controller.text = 'Nivel ${existingCount + 1}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(theme.icon, color: theme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Añadir Nivel',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textBrown, fontSize: 16)),
                  Text(biome, style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Nombre del nivel',
            prefixIcon: Icon(Icons.flag, color: theme.primary),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              GameState.instance.addLevel(controller.text.trim(), biome: biome);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('"${controller.text.trim()}" agregado a $biome'),
                  ]),
                  backgroundColor: const Color(0xFF27AE60),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Eliminar bioma completo ──────────────────────────────────────
  void _confirmDeleteBiome(String biome) {
    final theme = _getTheme(biome);
    final levelCount = GameState.instance.levels.value.where((l) => l.biome == biome).length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Eliminar Mundo',
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textBrown, fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Text(theme.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(biome,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark)),
                        Text('$levelCount nivel${levelCount == 1 ? '' : 'es'} y todas sus preguntas',
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              GameState.instance.deleteBiome(biome);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    const Icon(Icons.delete_sweep, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Bioma "$biome" eliminado'),
                  ]),
                  backgroundColor: Colors.orange.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('Eliminar todo', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Eliminar nivel individual ────────────────────────────────────
  void _confirmDeleteLevel(LevelData level) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¿Eliminar nivel?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Se eliminará "${level.title}" del bioma ${level.biome}.\nLas preguntas asociadas se perderán.',
          style: TextStyle(color: Colors.grey.shade700, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              GameState.instance.deleteLevel(level.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${level.title}" eliminado'),
                  backgroundColor: Colors.orange.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── BUILD ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBiomeDialog,
        heroTag: 'add_biome',
        backgroundColor: const Color(0xFF2B9BF4),
        elevation: 6,
        icon: const Icon(Icons.public, color: Colors.white),
        label: const Text('Nuevo Mundo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBrown),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestión de Mundos',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textBrown,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Biomas, niveles y preguntas',
                          style: TextStyle(
                            color: AppColors.textDark.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Biome list ──
            Expanded(
              child: ValueListenableBuilder<List<LevelData>>(
                valueListenable: GameState.instance.levels,
                builder: (context, levels, _) {
                  // Agrupar por bioma preservando orden
                  final biomeOrder = <String>[];
                  final biomeMap = <String, List<LevelData>>{};
                  for (final level in levels) {
                    if (!biomeMap.containsKey(level.biome)) {
                      biomeOrder.add(level.biome);
                      biomeMap[level.biome] = [];
                    }
                    biomeMap[level.biome]!.add(level);
                  }

                  if (biomeOrder.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.public_off, size: 56, color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 20),
                          Text('No hay mundos creados',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                          const SizedBox(height: 8),
                          Text('Toca "Nuevo Mundo" para empezar',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: biomeOrder.length,
                    itemBuilder: (context, index) {
                      final biome = biomeOrder[index];
                      final biomeLevels = biomeMap[biome]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _BiomeCard(
                          biome: biome,
                          levels: biomeLevels,
                          onAddLevel: () => _showAddLevelDialog(biome),
                          onDeleteBiome: () => _confirmDeleteBiome(biome),
                          onDeleteLevel: _confirmDeleteLevel,
                          onTapLevel: (level) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeacherQuestionManagementScreen(initialLevelId: level.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Biome Card Widget ─────────────────────────────────────────────
class _BiomeCard extends StatelessWidget {
  final String biome;
  final List<LevelData> levels;
  final VoidCallback onAddLevel;
  final VoidCallback onDeleteBiome;
  final ValueChanged<LevelData> onDeleteLevel;
  final ValueChanged<LevelData> onTapLevel;

  const _BiomeCard({
    required this.biome,
    required this.levels,
    required this.onAddLevel,
    required this.onDeleteBiome,
    required this.onDeleteLevel,
    required this.onTapLevel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme(biome);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header con gradiente ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary, theme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Text(theme.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        biome.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${levels.length} nivel${levels.length == 1 ? '' : 'es'}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Menú
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    if (value == 'delete') onDeleteBiome();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep, color: Colors.red.shade400, size: 20),
                          const SizedBox(width: 8),
                          const Text('Eliminar mundo', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Lista de niveles ──
          ...levels.asMap().entries.map((entry) {
            final idx = entry.key;
            final level = entry.value;
            return Dismissible(
              key: ValueKey('level-${level.id}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                onDeleteLevel(level);
                return false; // No dismiss, el dialog controla
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                color: Colors.red.shade400,
                child: const Icon(Icons.delete_forever, color: Colors.white, size: 28),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTapLevel(level),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: idx < levels.length - 1 ? Colors.grey.shade100 : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Toca para gestionar preguntas',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // ── Botón agregar nivel ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddLevel,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: theme.primary, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Añadir nivel',
                      style: TextStyle(
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
