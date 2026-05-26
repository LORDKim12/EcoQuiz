import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '../../../student/domain/models/game_state.dart';
import '../../../student/domain/models/quiz_model.dart';
import '../../../../core/constants/app_colors.dart';

class TeacherQuestionManagementScreen extends ConsumerStatefulWidget {
  final int? initialLevelId;
  const TeacherQuestionManagementScreen({super.key, this.initialLevelId});

  @override
  ConsumerState<TeacherQuestionManagementScreen> createState() =>
      _TeacherQuestionManagementScreenState();
}

class _TeacherQuestionManagementScreenState
    extends ConsumerState<TeacherQuestionManagementScreen> {
  final List<_QuestionFormData> _questions = [_QuestionFormData()];
  final TextEditingController _levelNameController = TextEditingController();
  String? _selectedBackgroundPath;

  final List<Map<String, String>> _backgroundOptions = [
    {'path': 'assets/images/biome_city_1779232580447.png', 'label': 'Ciudad'},
    {'path': 'assets/images/biome_mangrove_1779232638084.png', 'label': 'Manglar'},
    {'path': 'assets/images/biome_reef_1779232742390.png', 'label': 'Arrecife'},
    {'path': 'assets/images/desert_jungle_map_bg_1778450873966.png', 'label': 'Desierto/Selva'},
  ];

  @override
  void initState() {
    super.initState();
    // Cargar datos existentes si estamos editando un nivel
    if (widget.initialLevelId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final gameState = context.read<GameState>();
        final level = gameState.levels.firstWhere((l) => l.id == widget.initialLevelId, 
            orElse: () => throw Exception('Nivel no encontrado'));
        
        setState(() {
          _levelNameController.text = level.title;
          _selectedBackgroundPath = level.backgroundImagePath;
          
          if (level.questions.isNotEmpty) {
            _questions.clear();
            for (final q in level.questions) {
              final formData = _QuestionFormData();
              formData.questionController.text = q.questionText;
              
              for (int i = 0; i < q.options.length && i < 3; i++) {
                formData.optionControllers[i].text = q.options[i];
              }
              
              formData.correctIndex = q.correctOptionIndex;
              formData.hintController.text = q.hint;
              formData.funFactController.text = q.funFact;
              _questions.add(formData);
            }
          }
        });
      });
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionFormData());
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() => _questions.removeAt(index));
    }
  }

  void _showBackgroundPicker() {
    showDialog(
      context: context,
      builder: (context) {
        String? customPath;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFDF8F5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.public, size: 22, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Fondo del Bioma',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBrown)),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecciona una imagen predefinida:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            fontSize: 14)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _backgroundOptions.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final opt = _backgroundOptions[index];
                          final isSelected =
                              _selectedBackgroundPath == opt['path'];
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                customPath = null;
                              });
                              setState(() {
                                _selectedBackgroundPath = opt['path'];
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF27AE60)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 3 : 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      opt['path']!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(opt['label']!,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('O escribe una ruta personalizada:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'assets/images/mi_bioma.png',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (val) =>
                          setDialogState(() => customPath = val),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: customPath != null &&
                                customPath!.trim().isNotEmpty
                            ? () {
                                setState(() {
                                  _selectedBackgroundPath =
                                      customPath!.trim();
                                });
                                Navigator.pop(context);
                              }
                            : null,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Usar Ruta Personalizada',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B9BF4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _validateAndSave() {
    final name = _levelNameController.text.trim();
    if (widget.initialLevelId == null) {
      if (name.isEmpty) {
        _showError('El nombre del nivel no puede estar vacío.');
        return false;
      }
    }

    // Validar que al menos la primera pregunta esté completa
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.questionController.text.trim().isEmpty) {
        _showError('La pregunta ${i + 1} está vacía.');
        return false;
      }
      for (int j = 0; j < 3; j++) {
        if (q.optionControllers[j].text.trim().isEmpty) {
          _showError('La opción ${j + 1} de la pregunta ${i + 1} está vacía.');
          return false;
        }
      }
    }

    // Construir preguntas
    final questions = _questions.map((q) {
      return QuizQuestion(
        questionText: q.questionController.text.trim(),
        imageAssetPath: _selectedBackgroundPath ?? 'assets/images/eco_ajolote_mascot.png',
        options: q.optionControllers.map((c) => c.text.trim()).toList(),
        correctOptionIndex: q.correctIndex,
        hint: q.hintController.text.trim().isEmpty
            ? '¡Piensa bien!'
            : q.hintController.text.trim(),
        funFact: q.funFactController.text.trim().isEmpty
            ? '¡Dato interesante!'
            : q.funFactController.text.trim(),
      );
    }).toList();

    if (widget.initialLevelId != null) {
      context.read<GameState>().addQuestionsToLevel(widget.initialLevelId!, questions);
    } else {
      context.read<GameState>().addLevelWithQuestions(name, _selectedBackgroundPath, questions);
    }
    return true;
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
    _levelNameController.dispose();
    for (final q in _questions) {
      q.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.initialLevelId != null ? 'Agregar Preguntas' : 'Crear Nivel',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textBrown,
                fontWeight: FontWeight.w900,
              ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                if (_validateAndSave()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.camera_alt, size: 24, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(widget.initialLevelId != null ? '¡Preguntas agregadas exitosamente!' : '¡Nivel creado exitosamente!',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      backgroundColor: const Color(0xFF27AE60),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save, color: Colors.white, size: 18),
              label: const Text('Guardar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            if (isWide) {
              // ── Desktop: dos columnas ──
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna izquierda: config del nivel
                  if (widget.initialLevelId == null) ...[
                    SizedBox(
                      width: 340,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildLevelConfigSection(),
                      ),
                    ),
                    // Divisor vertical
                    Container(
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                  ],
                  // Columna derecha: preguntas
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildQuestionsSection(),
                    ),
                  ),
                ],
              );
            }

            // ── Móvil: lista vertical ──
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.initialLevelId == null) ...[
                    _buildLevelConfigSection(),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                  _buildQuestionsSection(),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECCIÓN: Configuración del nivel
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildLevelConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        const Row(
          children: [
            Text('🌎', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Configuración del Nivel',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBrown)),
          ],
        ),
        const SizedBox(height: 16),

        // Campo nombre
        TextField(
          controller: _levelNameController,
          decoration: InputDecoration(
            labelText: 'Nombre del bioma',
            hintText: 'Ej: Tundra Ártica',
            prefixIcon: const Icon(Icons.terrain, color: Color(0xFF27AE60)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFF27AE60), width: 2)),
          ),
        ),
        const SizedBox(height: 20),

        // Botón de imagen de fondo
        GestureDetector(
          onTap: _showBackgroundPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _selectedBackgroundPath != null
                      ? const Color(0xFF27AE60)
                      : Colors.grey.shade300,
                  width: 2),
            ),
            child: Column(
              children: [
                if (_selectedBackgroundPath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      _selectedBackgroundPath!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 40, color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF27AE60), size: 18),
                      const SizedBox(width: 6),
                      Text('Imagen seleccionada',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700)),
                    ],
                  ),
                ] else ...[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EAF8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_photo_alternate,
                        color: Color(0xFF2B9BF4), size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text('Seleccionar Foto de Fondo',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Opcional — se usará la mascota por defecto',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Estadísticas rápidas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFD5F5E3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.quiz, color: Color(0xFF1E8449), size: 22),
              const SizedBox(width: 10),
              Text('${_questions.length} pregunta${_questions.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E8449),
                      fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECCIÓN: Lista de preguntas
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('📝', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Preguntas del Nivel',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBrown)),
          ],
        ),
        const SizedBox(height: 16),

        // Cada pregunta
        ...List.generate(_questions.length, (index) {
          return _buildQuestionCard(index);
        }),

        const SizedBox(height: 16),

        // Botón agregar pregunta
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add_circle_outline,
                color: Color(0xFF2B9BF4)),
            label: const Text('Agregar Pregunta',
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
    );
  }

  Widget _buildQuestionCard(int index) {
    final q = _questions[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la pregunta
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFF39C12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Text('Pregunta ${index + 1}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.textBrown)),
              const Spacer(),
              if (_questions.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeQuestion(index),
                  tooltip: 'Eliminar pregunta',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Texto de la pregunta
          TextField(
            controller: q.questionController,
            maxLines: 2,
            decoration: _inputDecoration('¿Cuál es tu pregunta?', Icons.help_outline),
          ),
          const SizedBox(height: 14),

          // 3 opciones de respuesta
          ...List.generate(3, (optIndex) {
            final colors = [
              const Color(0xFF4CAF50),
              const Color(0xFF2196F3),
              const Color(0xFFFF9800),
            ];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: q.optionControllers[optIndex],
                decoration: InputDecoration(
                  labelText: 'Opción ${optIndex + 1}',
                  prefixIcon: Icon(
                    q.correctIndex == optIndex
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: colors[optIndex],
                  ),
                  filled: true,
                  fillColor: q.correctIndex == optIndex
                      ? colors[optIndex].withValues(alpha: 0.08)
                      : Colors.grey.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: q.correctIndex == optIndex
                              ? colors[optIndex]
                              : Colors.grey.shade300,
                          width: q.correctIndex == optIndex ? 2 : 1)),
                ),
              ),
            );
          }),

          // Selector de respuesta correcta
          const SizedBox(height: 4),
          const Text('Respuesta correcta:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontSize: 13)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Op. 1')),
              ButtonSegment(value: 1, label: Text('Op. 2')),
              ButtonSegment(value: 2, label: Text('Op. 3')),
            ],
            selected: {q.correctIndex},
            onSelectionChanged: (set) {
              setState(() => q.correctIndex = set.first);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF27AE60);
                }
                return Colors.white;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppColors.textDark;
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Pista
          TextField(
            controller: q.hintController,
            decoration: _inputDecoration('Pista para el alumno (opcional)', Icons.lightbulb_outline),
          ),
          const SizedBox(height: 10),

          // Dato curioso
          TextField(
            controller: q.funFactController,
            maxLines: 2,
            decoration: _inputDecoration('¿Sabías que...? (dato curioso, opcional)', Icons.auto_awesome),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2B9BF4), width: 2)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

/// Datos editables de una pregunta dentro del formulario.
class _QuestionFormData {
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers =
      List.generate(3, (_) => TextEditingController());
  final TextEditingController hintController = TextEditingController();
  final TextEditingController funFactController = TextEditingController();
  int correctIndex = 0;

  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
    hintController.dispose();
    funFactController.dispose();
  }
}
