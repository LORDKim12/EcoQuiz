import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/models/models.dart';

class TeacherQuestionManagementScreen extends ConsumerStatefulWidget {
  final int? initialLevelId;
  const TeacherQuestionManagementScreen({super.key, this.initialLevelId});

  @override
  ConsumerState<TeacherQuestionManagementScreen> createState() =>
      _TeacherQuestionManagementScreenState();
}

class _TeacherQuestionManagementScreenState
    extends ConsumerState<TeacherQuestionManagementScreen> {
  List<LevelModel> _levels = [];
  Map<int, List<QuestionModel>> _questionsByLevel = {};
  int _selectedLevelId = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedLevelId = widget.initialLevelId ?? 0;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final teacherService = ref.read(teacherServiceProvider);
      // Cargar niveles de Supabase (no del GameState) para que los IDs coincidan
      _levels = await teacherService.getLevels();

      _questionsByLevel = {};
      final client = supabase_flutter.Supabase.instance.client;
      for (final level in _levels) {
        final result = await client
            .from('questions')
            .select()
            .eq('level_id', level.id);
        _questionsByLevel[level.id] = result
            .map((json) => QuestionModel.fromJson(json))
            .toList();
      }
      if (_levels.isNotEmpty && !_levels.any((l) => l.id == _selectedLevelId)) {
        _selectedLevelId = _levels.first.id;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddQuestionDialog() {
    final textController = TextEditingController();
    final option1Controller = TextEditingController();
    final option2Controller = TextEditingController();
    final option3Controller = TextEditingController();
    final hintController = TextEditingController();
    final funFactController = TextEditingController();
    int correctIndex = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Nueva Pregunta',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBrown)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(textController, 'Pregunta', Icons.help_outline, maxLines: 2),
                const SizedBox(height: 12),
                _buildTextField(option1Controller, 'Opción 1', Icons.looks_one),
                const SizedBox(height: 8),
                _buildTextField(option2Controller, 'Opción 2', Icons.looks_two),
                const SizedBox(height: 8),
                _buildTextField(option3Controller, 'Opción 3', Icons.looks_3),
                const SizedBox(height: 12),
                const Text('Respuesta correcta:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(3, (i) => Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => correctIndex = i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: correctIndex == i
                              ? Colors.green.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: correctIndex == i
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: correctIndex == i
                                    ? Colors.green.shade800
                                    : Colors.grey,
                              )),
                        ),
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 12),
                _buildTextField(hintController, 'Pista', Icons.lightbulb_outline),
                const SizedBox(height: 8),
                _buildTextField(funFactController, '¿Sabías que...?', Icons.auto_awesome, maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (textController.text.isEmpty ||
                    option1Controller.text.isEmpty ||
                    option2Controller.text.isEmpty ||
                    option3Controller.text.isEmpty) {
                  return;
                }
                Navigator.pop(ctx);
                await _addQuestion(
                  questionText: textController.text,
                  options: [
                    option1Controller.text,
                    option2Controller.text,
                    option3Controller.text,
                  ],
                  correctIndex: correctIndex,
                  hint: hintController.text,
                  funFact: funFactController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teacherBorder,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _addQuestion({
    required String questionText,
    required List<String> options,
    required int correctIndex,
    required String hint,
    required String funFact,
  }) async {
    try {
      // Usamos el cliente de Supabase directamente para insertar
      final client = supabase_flutter.Supabase.instance.client;
      await client.from('questions').insert({
        'level_id': _selectedLevelId,
        'question_text': questionText,
        'image_url': 'assets/images/eco_ajolote_mascot.png',
        'options': options,
        'correct_index': correctIndex,
        'hint': hint.isEmpty ? 'Piensa bien la respuesta.' : hint,
        'fun_fact': funFact.isEmpty ? '¡Sigue aprendiendo!' : funFact,
      });
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pregunta agregada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      final client = supabase_flutter.Supabase.instance.client;
      await client.from('questions').delete().eq('id', questionId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta eliminada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
          'Banco de Preguntas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddQuestionDialog,
        backgroundColor: AppColors.teacherBorder,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Pregunta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Selector de nivel ──
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _levels.length,
                    itemBuilder: (context, index) {
                      final level = _levels[index];
                      final isSelected = level.id == _selectedLevelId;
                      final count = _questionsByLevel[level.id]?.length ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text('${level.biome.toUpperCase()} - ${level.title} ($count)'),
                          selectedColor: AppColors.teacherBorder.withOpacity(0.2),
                          checkmarkColor: AppColors.teacherBorder,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.teacherBorder : Colors.grey.shade600,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => setState(() => _selectedLevelId = level.id),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ── Lista de preguntas ──
                Expanded(
                  child: _buildQuestionList(),
                ),
              ],
            ),
    );
  }

  Widget _buildQuestionList() {
    final questions = _questionsByLevel[_selectedLevelId] ?? [];

    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No hay preguntas para este nivel',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca + para agregar una',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.teacherBorder.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${index + 1}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.teacherBorder)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q.questionText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Colors.red.shade300, size: 22),
                      onPressed: () => _confirmDelete(q.id),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: q.options.asMap().entries.map((entry) {
                    final isCorrect = entry.key == q.correctIndex;
                    return Chip(
                      label: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 12,
                          color: isCorrect ? Colors.green.shade800 : Colors.grey.shade700,
                          fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      backgroundColor: isCorrect
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      side: BorderSide(
                        color: isCorrect ? Colors.green : Colors.grey.shade300,
                      ),
                      avatar: isCorrect
                          ? const Icon(Icons.check_circle, size: 16, color: Colors.green)
                          : null,
                    );
                  }).toList(),
                ),
                if (q.hint.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('💡 ${q.hint}',
                      style: TextStyle(fontSize: 12, color: Colors.amber.shade700)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(String questionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¿Eliminar pregunta?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteQuestion(questionId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
