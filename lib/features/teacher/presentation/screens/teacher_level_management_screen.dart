
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../student/domain/models/game_state.dart';
import 'teacher_question_management_screen.dart';
import 'package:provider/provider.dart';

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
  return const _BiomeTheme(
    primary: Color(0xFF7E57C2),
    secondary: Color(0xFFB39DDB),
    icon: Icons.public,
    emoji: '🌍',
  );
}

String _getBiomeImage(String biome) {
  final lower = biome.toLowerCase();
  if (lower.contains('tundra')) return 'assets/images/biome_tundra.png';
  if (lower.contains('desierto')) return 'assets/images/biome_desert.png';
  if (lower.contains('selva')) return 'assets/images/biome_jungle.png';
  if (lower.contains('bosque')) return 'assets/images/biome_forest.png';
  if (lower.contains('ciudad')) return 'assets/images/biome_city.png';
  if (lower.contains('manglar')) return 'assets/images/biome_mangrove.png';
  if (lower.contains('arrecife')) return 'assets/images/biome_reef.png';
  return 'assets/images/biome_forest.png';
}

// ── Pantalla principal ─────────────────────────────────────────────
class TeacherLevelManagementScreen extends StatefulWidget {
  const TeacherLevelManagementScreen({super.key});

  @override
  State<TeacherLevelManagementScreen> createState() =>
      _TeacherLevelManagementScreenState();
}

class _TeacherLevelManagementScreenState
    extends State<TeacherLevelManagementScreen> {
  // Biomas expandidos
  final Set<String> _expandedBiomes = {};

  /// Agrupa niveles por bioma
  Map<String, List<LevelData>> _groupByBiome(List<LevelData> levels) {
    final grouped = <String, List<LevelData>>{};
    for (final level in levels) {
      grouped.putIfAbsent(level.biome, () => []);
      grouped[level.biome]!.add(level);
    }
    return grouped;
  }

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
              child:
                  const Icon(Icons.public, color: Color(0xFF2B9BF4), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Nuevo Mundo',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.textBrown)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crea un nuevo bioma/mundo para organizar tus niveles.',
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Ej. Tundra, Volcán, Sabana…',
                prefixIcon:
                    const Icon(Icons.terrain, color: Color(0xFF2B9BF4)),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Color(0xFF2B9BF4), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final existing = context
                  .read<GameState>()
                  .levels
                  .map((l) => l.biome.toLowerCase())
                  .toSet();
              if (existing.contains(name.toLowerCase())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('El bioma "$name" ya existe'),
                      backgroundColor: Colors.orange),
                );
                return;
              }
              context.read<GameState>().addLevel('Nivel 1', biome: name);
              Navigator.pop(ctx);
              setState(() => _expandedBiomes.add(name));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Bioma "$name" creado con Nivel 1'),
                  ]),
                  backgroundColor: const Color(0xFF27AE60),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Crear',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B9BF4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Agregar nivel (nodo) a un bioma ─────────────────────────────
  void _showAddLevelDialog(String biome) {
    final controller = TextEditingController();
    final theme = _getTheme(biome);
    final existingCount =
        context.read<GameState>().levels.where((l) => l.biome == biome).length;
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
            Flexible(
              child: Text('Nuevo Nodo en $biome',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBrown,
                      fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Este nodo aparecerá en el mapa del alumno como una nueva parada.',
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nombre del nodo',
                hintText: 'Ej. Nivel 3, Desafío final…',
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              context
                  .read<GameState>()
                  .addLevel(controller.text.trim(), biome: biome);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('"${controller.text.trim()}" agregado a $biome'),
                  ]),
                  backgroundColor: const Color(0xFF27AE60),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Editar nombre de un nivel ───────────────────────────────────
  void _showEditLevelDialog(LevelData level) {
    final controller = TextEditingController(text: level.title);
    final theme = _getTheme(level.biome);

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
              child: Icon(Icons.edit, color: theme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Editar Nodo',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.textBrown)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nombre del nodo',
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              context
                  .read<GameState>()
                  .renameLevel(level.id, controller.text.trim());
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Guardar',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirmar eliminación de nodo ───────────────────────────────
  void _confirmDeleteLevel(LevelData level) {
    final theme = _getTheme(level.biome);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Eliminar Nodo',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.textBrown)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(
                color: Colors.grey.shade700, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: '¿Estás seguro de eliminar '),
              TextSpan(
                text: '"${level.title}"',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: theme.primary),
              ),
              const TextSpan(text: '?\n\nSe eliminarán todas sus preguntas.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.read<GameState>().deleteLevel(level.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${level.title}" eliminado'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirmar eliminación de bioma completo ─────────────────────
  void _confirmDeleteBiome(String biome, int levelCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.warning_amber,
                  color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Eliminar Mundo',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.textBrown)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(
                color: Colors.grey.shade700, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Eliminarás el bioma '),
              TextSpan(
                text: '"$biome"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text:
                      ' con $levelCount nivel${levelCount != 1 ? 'es' : ''} y todas sus preguntas.'),
              const TextSpan(
                  text: '\n\nEsta acción no se puede deshacer.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.read<GameState>().deleteBiome(biome);
              _expandedBiomes.remove(biome);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bioma "$biome" eliminado'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('Eliminar Todo',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBiomeDialog,
        backgroundColor: const Color(0xFF2B9BF4),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Mundo',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mundos y Nodos',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.textBrown,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configura los biomas y niveles del mapa',
                          style: TextStyle(
                            color: AppColors.textDark.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Biome list
            Expanded(
              child: Consumer<GameState>(
                builder: (context, gameState, child) {
                  final levels = gameState.levels;

                  if (levels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.explore_off,
                              size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No hay mundos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea tu primer mundo con el botón "Nuevo Mundo"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final biomeGroups = _groupByBiome(levels);
                  final biomeNames = biomeGroups.keys.toList();

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(bottom: 100),
                    itemCount: biomeNames.length,
                    itemBuilder: (context, index) {
                      final biomeName = biomeNames[index];
                      final biomeLevels = biomeGroups[biomeName]!;
                      return _buildBiomeSection(biomeName, biomeLevels);
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

  // ═══════════════════════════════════════════════════════════════════
  // Sección de un bioma con sus niveles
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBiomeSection(String biomeName, List<LevelData> levels) {
    final theme = _getTheme(biomeName);
    final biomeImage = _getBiomeImage(biomeName);
    final isExpanded = _expandedBiomes.contains(biomeName);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // ── Header del bioma (tap para expandir) ──
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedBiomes.remove(biomeName);
                  } else {
                    _expandedBiomes.add(biomeName);
                  }
                });
              },
              child: SizedBox(
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      biomeImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(color: theme.primary),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(theme.icon,
                                  color: Colors.white, size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  biomeName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black38,
                                          blurRadius: 4)
                                    ],
                                  ),
                                ),
                              ),
                              // Conteo de niveles
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${levels.length} ${levels.length == 1 ? 'nodo' : 'nodos'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Botón opciones
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.white),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                onSelected: (value) {
                                  if (value == 'add') {
                                    _showAddLevelDialog(biomeName);
                                  } else if (value == 'delete') {
                                    _confirmDeleteBiome(
                                        biomeName, levels.length);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'add',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_circle_outline,
                                            color: Color(0xFF27AE60)),
                                        SizedBox(width: 8),
                                        Text('Agregar nodo'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Eliminar mundo',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Flecha expandir
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.expand_more,
                                    color: Colors.white, size: 28),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Lista de niveles (expandible) ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    ...levels.asMap().entries.map((entry) {
                      final i = entry.key;
                      final level = entry.value;
                      return _buildLevelTile(level, i, theme);
                    }),
                    // Botón agregar nodo
                    InkWell(
                      onTap: () => _showAddLevelDialog(biomeName),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline,
                                color: theme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Agregar nodo',
                              style: TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Tile de un nivel individual dentro del bioma
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildLevelTile(LevelData level, int index, _BiomeTheme theme) {
    final questionCount = level.questions.length;
    final isOriginal = level.id <= 5;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: index > 0
              ? BorderSide(color: Colors.grey.shade200)
              : BorderSide.none,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.primary, theme.secondary],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                level.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textBrown,
                ),
              ),
            ),
            if (isOriginal)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Original',
                  style: TextStyle(
                    color: Color(0xFF27AE60),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.quiz, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '$questionCount pregunta${questionCount != 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                level.isUnlocked ? Icons.lock_open : Icons.lock,
                size: 14,
                color: level.isUnlocked
                    ? const Color(0xFF27AE60)
                    : Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                level.isUnlocked ? 'Activo' : 'Bloqueado',
                style: TextStyle(
                  color: level.isUnlocked
                      ? const Color(0xFF27AE60)
                      : Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
          onSelected: (value) {
            switch (value) {
              case 'questions':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeacherQuestionManagementScreen(
                        initialLevelId: level.id),
                  ),
                );
                break;
              case 'edit':
                _showEditLevelDialog(level);
                break;
              case 'toggle':
                context
                    .read<GameState>()
                    .setLevelUnlocked(level.id, !level.isUnlocked);
                break;
              case 'delete':
                _confirmDeleteLevel(level);
                break;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'questions',
              child: Row(
                children: [
                  Icon(Icons.quiz, color: Color(0xFF2B9BF4)),
                  SizedBox(width: 8),
                  Text('Gestionar preguntas'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFFF39C12)),
                  SizedBox(width: 8),
                  Text('Editar nombre'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    level.isUnlocked ? Icons.lock : Icons.lock_open,
                    color: const Color(0xFF27AE60),
                  ),
                  const SizedBox(width: 8),
                  Text(level.isUnlocked ? 'Bloquear' : 'Desbloquear'),
                ],
              ),
            ),
            if (!isOriginal)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
        onTap: () {
          // Tap directo → ir a preguntas
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherQuestionManagementScreen(
                  initialLevelId: level.id),
            ),
          );
        },
      ),
    );
  }
}
