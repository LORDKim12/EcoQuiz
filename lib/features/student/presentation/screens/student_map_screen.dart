import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/level_node_button.dart';
import '../widgets/map_path_painter.dart';
import '../../domain/models/quiz_model.dart';
import 'student_quiz_screen.dart';

class StudentMapScreen extends StatefulWidget {
  const StudentMapScreen({super.key});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Total map height
  final double _mapHeight = 1500.0;

  // Node relative positions (from bottom to top)
  // X is horizontal percentage (0.0 to 1.0)
  // Y is vertical absolute position from TOP
  final List<Offset> _nodePositions = [
    const Offset(0.3, 1350), // Nivel 1: Ciudad (bottom)
    const Offset(0.6, 1150), // Nivel 2: Manglar
    const Offset(0.4, 900),  // Nivel 3: Arrecife
    const Offset(0.7, 650),  // Nivel 4: Bosque
    const Offset(0.3, 400),  // Nivel 5: Selva
    const Offset(0.6, 150),  // Nivel 6: Desierto (top)
  ];

  @override
  void initState() {
    super.initState();
    // Scroll to the bottom when the screen opens so the player starts at level 1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Convert relative node positions to absolute canvas coordinates
        final List<Offset> absolutePoints = _nodePositions.map((p) {
          return Offset(p.dx * screenWidth, p.dy);
        }).toList();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: _buildCustomAppBar(context),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: screenWidth,
              height: _mapHeight,
              child: Stack(
            children: [
              // 1. Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/biome_map_bg_1778462946588.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFFE67E22), // Desert orange
                            Color(0xFFF1C40F), // Sand yellow
                            Color(0xFF27AE60), // Jungle green
                            Color(0xFF1E8449), // Deep jungle
                          ],
                          stops: [0.0, 0.3, 0.6, 1.0],
                        ),
                      ),
                      child: const Center(child: Text('Fondo de Mapa')),
                    );
                  },
                ),
              ),

              // 2. Dashed Path connecting the nodes
              Positioned.fill(
                child: CustomPaint(
                  painter: MapPathPainter(
                    points: absolutePoints,
                    pathColor: const Color(0xFFFAE5D3), // Light sandy color
                    strokeWidth: 12.0,
                  ),
                ),
              ),

              // 3. Level Nodes
              ...List.generate(6, (index) {
                final pos = absolutePoints[index];
                
                // Allow clicking all levels for testing
                LevelStatus status = LevelStatus.completed;
                int stars = 3;
                if (index == 4) {
                  status = LevelStatus.current;
                  stars = 0;
                } else if (index == 5) {
                  status = LevelStatus.current;
                  stars = 0;
                }

                return Positioned(
                  left: pos.dx - 35, // center horizontally (approx half of node width)
                  top: pos.dy - 35,  // center vertically
                  child: LevelNodeButton(
                    levelNumber: index + 1,
                    status: status,
                    stars: stars,
                    onTap: () {
                      if (status != LevelStatus.locked) {
                        final List<QuizQuestion> biomeQuestions = _getQuestionsForBiome(index);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentQuizScreen(
                              questions: biomeQuestions,
                              levelIndex: index,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              }),

              // 4. Avatar (Eco the Ajolote) hovering near current level (Level 3)
              Positioned(
                left: absolutePoints[2].dx - 60,
                top: absolutePoints[2].dy - 90,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/eco_ajolote.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.pink.shade200),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
}

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withOpacity(0.95),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Logo
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
          // Star Counter Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF39C12), // Orange
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF873600), width: 2), // Dark orange/brown border
            ),
            child: const Row(
              children: [
                Icon(Icons.star_border, color: Colors.white, size: 20),
                SizedBox(width: 4),
                Text(
                  '124',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Settings Icon
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

  List<QuizQuestion> _getQuestionsForBiome(int index) {
    switch (index) {
      case 0: // Ciudad
        return [
          const QuizQuestion(
            questionText: '¿Cuál es la regla de las 3 R en la ciudad para cuidar el medio ambiente?',
            imageAssetPath: 'assets/images/eco_ajolote_mascot.png',
            options: ['Robar, Romper, Reír', 'Reducir, Reutilizar, Reciclar', 'Rápido, Ruidoso, Raro'],
            correctOptionIndex: 1,
            hint: 'Son acciones para generar menos basura.',
            funFact: 'Reciclar una lata de aluminio ahorra suficiente energía para encender una TV por 3 horas.',
          ),
        ];
      case 1: // Manglar
        return [
          const QuizQuestion(
            questionText: '¿Qué característica especial tienen los árboles del manglar?',
            imageAssetPath: 'assets/images/eco_ajolote_mascot.png',
            options: ['Crecen en la nieve', 'Sus raíces crecen en agua salada', 'No necesitan agua'],
            correctOptionIndex: 1,
            hint: 'Viven donde se junta el río con el mar.',
            funFact: 'Los manglares protegen las costas de los huracanes como si fueran escudos naturales.',
          ),
        ];
      case 2: // Arrecife
        return [
          const QuizQuestion(
            questionText: '¿Los corales del arrecife son plantas o animales?',
            imageAssetPath: 'assets/images/eco_ajolote_mascot.png',
            options: ['Plantas', 'Animales', 'Piedras de colores'],
            correctOptionIndex: 1,
            hint: 'Aunque no se mueven de lugar, están vivos y comen plancton.',
            funFact: 'Los corales son en realidad animales diminutos llamados pólipos que construyen grandes esqueletos de calcio.',
          ),
        ];
      case 3: // Bosque
        return [
          const QuizQuestion(
            questionText: '¿Qué asombroso animal migra miles de kilómetros hacia los bosques de México?',
            imageAssetPath: 'assets/images/eco_ajolote_mascot.png',
            options: ['Oso pardo', 'Mariposa Monarca', 'Pingüino Emperador'],
            correctOptionIndex: 1,
            hint: 'Es un insecto volador de color naranja y negro.',
            funFact: 'La mariposa monarca viaja desde Canadá hasta los bosques de Michoacán cada invierno.',
          ),
        ];
      case 4: // Selva
        return [
          const QuizQuestion(
            questionText: '¿Cuál de estos felinos vive en la selva y sabe nadar muy bien?',
            imageAssetPath: 'assets/images/quiz_jaguar_1778457575331.png',
            options: ['Jaguar', 'León africano', 'Gato doméstico'],
            correctOptionIndex: 0,
            hint: 'Tiene hermosas manchas llamadas rosetas en su piel.',
            funFact: 'El jaguar es el felino más grande de toda América.',
          ),
        ];
      case 5: // Desierto
        return [
          const QuizQuestion(
            questionText: '¿Dónde almacenan el agua los cactus para sobrevivir en el desierto?',
            imageAssetPath: 'assets/images/eco_ajolote_mascot.png',
            options: ['En sus flores', 'En sus raíces', 'En sus gruesos tallos verdes'],
            correctOptionIndex: 2,
            hint: 'Es la parte grande, verde y carnosa de la planta.',
            funFact: '¡Un cactus gigante llamado Saguaro puede almacenar hasta 5,000 litros de agua en su interior!',
          ),
        ];
      default:
        return [];
    }
  }
}
