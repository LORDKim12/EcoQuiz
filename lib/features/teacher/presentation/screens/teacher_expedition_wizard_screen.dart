import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../student/domain/models/game_state.dart';
import '../../../student/domain/models/quiz_model.dart';
import '../../../../core/constants/app_colors.dart';

/// Wizard de 3 pasos para crear expediciones.
/// Paso 1: Nombre de la expedición
/// Paso 2: Selección visual del bioma
/// Paso 3: Configurar paradas y preguntas
class TeacherExpeditionWizardScreen extends StatefulWidget {
  const TeacherExpeditionWizardScreen({super.key});

  @override
  State<TeacherExpeditionWizardScreen> createState() =>
      _TeacherExpeditionWizardScreenState();
}

class _TeacherExpeditionWizardScreenState
    extends State<TeacherExpeditionWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Paso 1: Nombre
  final TextEditingController _titleController = TextEditingController();

  // Paso 2: Bioma
  String? _selectedBiomeImage;
  String _selectedBiomeName = '';

  // Paso 3: Paradas
  final List<_StopFormData> _stops = [_StopFormData(title: 'Parada 1')];

  static const List<Map<String, String>> _biomeOptions = [
    {'path': 'assets/images/biome_city.png', 'label': 'Ciudad', 'emoji': '🏙️'},
    {'path': 'assets/images/biome_mangrove.png', 'label': 'Manglar', 'emoji': '🌿'},
    {'path': 'assets/images/biome_reef.png', 'label': 'Arrecife', 'emoji': '🐠'},
    {'path': 'assets/images/biome_forest.png', 'label': 'Bosque', 'emoji': '🌲'},
    {'path': 'assets/images/biome_jungle.png', 'label': 'Selva', 'emoji': '🌴'},
    {'path': 'assets/images/biome_desert.png', 'label': 'Desierto', 'emoji': '🏜️'},
    {'path': 'assets/images/biome_tundra.png', 'label': 'Tundra', 'emoji': '❄️'},
  ];

  void _nextStep() {
    if (_currentStep == 0 && _titleController.text.trim().isEmpty) {
      _showError('Escribe el nombre de tu expedición');
      return;
    }
    if (_currentStep == 1 && _selectedBiomeImage == null) {
      _showError('Selecciona un bioma para tu expedición');
      return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _addStop() {
    setState(() {
      _stops.add(_StopFormData(title: 'Parada ${_stops.length + 1}'));
    });
  }

  void _removeStop(int index) {
    if (_stops.length > 1) {
      setState(() => _stops.removeAt(index));
    }
  }

  void _saveExpedition() {
    // Validar al menos una parada con preguntas
    bool hasAtLeastOneQuestion = false;
    for (final stop in _stops) {
      if (stop.questions.isNotEmpty) {
        hasAtLeastOneQuestion = true;
        break;
      }
    }

    if (!hasAtLeastOneQuestion) {
      _showError('Agrega al menos una pregunta en alguna parada');
      return;
    }

    // Construir las paradas como ExpeditionStop
    final expeditionStops = <ExpeditionStop>[];
    for (int i = 0; i < _stops.length; i++) {
      final stop = _stops[i];
      final stopTitle =
          stop.titleController.text.trim().isEmpty
              ? 'Parada ${i + 1}'
              : stop.titleController.text.trim();
      expeditionStops.add(ExpeditionStop(
        id: i,
        title: stopTitle,
        questions: stop.questions,
      ));
    }

    context.read<GameState>().addExpedition(
          _titleController.text.trim(),
          _selectedBiomeImage,
          expeditionStops,
          biome: _selectedBiomeName,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('¡Expedición creada exitosamente!',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
                child: Text(msg,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pageController.dispose();
    for (final s in _stops) {
      s.dispose();
    }
    super.dispose();
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
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Nueva Expedición',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textBrown,
                fontWeight: FontWeight.w900,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator
            _buildStepIndicator(),
            const SizedBox(height: 16),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Name(),
                  _buildStep2Biome(),
                  _buildStep3Stops(),
                ],
              ),
            ),

            // Bottom action buttons
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Step Indicator
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStepIndicator() {
    const icons = [Icons.edit, Icons.landscape, Icons.flag];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF27AE60)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 48 : 36,
                  height: isCurrent ? 48 : 36,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                          )
                        : null,
                    color: isActive ? null : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: const Color(0xFF27AE60).withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: isCurrent ? 20 : 16,
                        color: isActive ? Colors.white : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Step 1: Nombre de la Expedición
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStep1Name() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // Mascota
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF27AE60), width: 4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/eco_ajolote_mascot.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.pets, size: 50, color: Colors.green),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Cómo se llama tu\nexpedición?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textBrown,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dale un nombre emocionante para tus alumnos',
            style: TextStyle(
              color: AppColors.textDark.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _titleController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textBrown,
            ),
            decoration: InputDecoration(
              hintText: 'Ej: Aventura en la Selva',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    const BorderSide(color: Color(0xFF27AE60), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Step 2: Selección de Bioma (Grid visual)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStep2Biome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Elige el bioma',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textBrown,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      'Este será el fondo del mapa de tus alumnos',
                      style: TextStyle(
                        color: AppColors.textDark.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemCount: _biomeOptions.length,
            itemBuilder: (context, index) {
              final opt = _biomeOptions[index];
              final isSelected = _selectedBiomeImage == opt['path'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBiomeImage = opt['path'];
                    _selectedBiomeName = opt['label']!;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF27AE60)
                          : Colors.grey.shade200,
                      width: isSelected ? 4 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Imagen del bioma
                        Image.asset(
                          opt['path']!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.landscape,
                                size: 40, color: Colors.grey),
                          ),
                        ),
                        // Overlay glassmorphism
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(22)),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                color: Colors.white.withValues(alpha: 0.6),
                                child: Row(
                                  children: [
                                    Text(opt['emoji']!,
                                        style:
                                            const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        opt['label']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textBrown,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle,
                                          color: Color(0xFF27AE60),
                                          size: 22),
                                  ],
                                ),
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
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Step 3: Paradas (stops)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStep3Stops() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24).copyWith(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚩', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paradas de la Expedición',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textBrown,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      'Cada parada es un quiz que tus alumnos resolverán',
                      style: TextStyle(
                        color: AppColors.textDark.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stop cards
          ...List.generate(_stops.length, (index) {
            return _buildStopCard(index);
          }),

          const SizedBox(height: 12),

          // Add stop button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addStop,
              icon:
                  const Icon(Icons.add_circle_outline, color: Color(0xFF2B9BF4)),
              label: const Text('Agregar Parada',
                  style: TextStyle(
                      color: Color(0xFF2B9BF4), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2B9BF4), width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(int index) {
    final stop = _stops[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: index == 0,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF39C12), Color(0xFFF1C40F)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.3),
                  blurRadius: 8,
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
          title: Text(
            stop.titleController.text.isEmpty
                ? 'Parada ${index + 1}'
                : stop.titleController.text,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textBrown,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${stop.questions.length} pregunta${stop.questions.length != 1 ? 's' : ''}',
            style: TextStyle(
              color: stop.questions.isNotEmpty
                  ? const Color(0xFF27AE60)
                  : Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          trailing: _stops.length > 1
              ? IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 22),
                  onPressed: () => _removeStop(index),
                )
              : null,
          children: [
            // Title field
            TextField(
              controller: stop.titleController,
              decoration: InputDecoration(
                labelText: 'Nombre de la parada',
                hintText: 'Ej: Los Ríos de la Selva',
                prefixIcon: const Icon(Icons.flag, color: Color(0xFFF39C12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFF39C12), width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Questions mini list
            if (stop.questions.isNotEmpty) ...[
              ...List.generate(stop.questions.length, (qi) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5F5E3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.quiz, color: Color(0xFF1E8449), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stop.questions[qi].questionText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E8449),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            stop.questions.removeAt(qi);
                          });
                        },
                        child: const Icon(Icons.close,
                            color: Color(0xFF1E8449), size: 18),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 4),
            ],

            // Add question button (inline dialog)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddQuestionDialog(index),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Agregar Pregunta',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B9BF4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog(int stopIndex) {
    final questionCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController();
    final opt2Ctrl = TextEditingController();
    final opt3Ctrl = TextEditingController();
    final hintCtrl = TextEditingController();
    final funFactCtrl = TextEditingController();
    int correctIdx = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFDF8F5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD6EAF8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.quiz, color: Color(0xFF2B9BF4), size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Nueva Pregunta',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBrown,
                          fontSize: 18)),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogTextField(questionCtrl, '¿Cuál es tu pregunta?',
                        Icons.help_outline,
                        maxLines: 2),
                    const SizedBox(height: 10),
                    _dialogTextField(
                        opt1Ctrl, 'Opción 1', Icons.circle_outlined),
                    const SizedBox(height: 8),
                    _dialogTextField(
                        opt2Ctrl, 'Opción 2', Icons.circle_outlined),
                    const SizedBox(height: 8),
                    _dialogTextField(
                        opt3Ctrl, 'Opción 3', Icons.circle_outlined),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Respuesta correcta:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textDark)),
                    ),
                    const SizedBox(height: 6),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Op. 1')),
                        ButtonSegment(value: 1, label: Text('Op. 2')),
                        ButtonSegment(value: 2, label: Text('Op. 3')),
                      ],
                      selected: {correctIdx},
                      onSelectionChanged: (set) {
                        setDialogState(() => correctIdx = set.first);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF27AE60);
                          }
                          return Colors.white;
                        }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          return AppColors.textDark;
                        }),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _dialogTextField(
                        hintCtrl, 'Pista (opcional)', Icons.lightbulb_outline),
                    const SizedBox(height: 8),
                    _dialogTextField(
                        funFactCtrl, '¿Sabías que...? (opcional)', Icons.auto_awesome),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (questionCtrl.text.trim().isEmpty ||
                      opt1Ctrl.text.trim().isEmpty ||
                      opt2Ctrl.text.trim().isEmpty ||
                      opt3Ctrl.text.trim().isEmpty) {
                    return;
                  }
                  final q = QuizQuestion(
                    questionText: questionCtrl.text.trim(),
                    imageAssetPath: _selectedBiomeImage ??
                        'assets/images/eco_ajolote_mascot.png',
                    options: [
                      opt1Ctrl.text.trim(),
                      opt2Ctrl.text.trim(),
                      opt3Ctrl.text.trim(),
                    ],
                    correctOptionIndex: correctIdx,
                    hint: hintCtrl.text.trim().isEmpty
                        ? '¡Piensa bien!'
                        : hintCtrl.text.trim(),
                    funFact: funFactCtrl.text.trim().isEmpty
                        ? '¡Dato interesante!'
                        : funFactCtrl.text.trim(),
                  );
                  setState(() {
                    _stops[stopIndex].questions.add(q);
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Agregar',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _dialogTextField(
      TextEditingController ctrl, String hint, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2B9BF4), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Bottom Action Buttons
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress text
          Expanded(
            child: Text(
              'Paso ${_currentStep + 1} de 3',
              style: TextStyle(
                color: AppColors.textDark.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          // Action button
          if (_currentStep < 2)
            ElevatedButton.icon(
              onPressed: _nextStep,
              icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              label: const Text('Siguiente',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _saveExpedition,
              icon:
                  const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
              label: const Text('Crear Expedición',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }
}

/// Datos editables de una parada en el wizard
class _StopFormData {
  final TextEditingController titleController;
  final List<QuizQuestion> questions = [];

  _StopFormData({String title = ''})
      : titleController = TextEditingController(text: title);

  void dispose() {
    titleController.dispose();
  }
}
