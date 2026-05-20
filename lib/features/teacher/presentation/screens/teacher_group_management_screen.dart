import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../student/domain/models/game_state.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/models/models.dart';

class TeacherGroupManagementScreen extends ConsumerStatefulWidget {
  const TeacherGroupManagementScreen({super.key});

  @override
  ConsumerState<TeacherGroupManagementScreen> createState() => _TeacherGroupManagementScreenState();
}

class _TeacherGroupManagementScreenState extends ConsumerState<TeacherGroupManagementScreen> {
  List<GroupModel> _groups = [];
  List<UserModel> _students = [];
  GroupModel? _selectedGroup;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);
    try {
      final teacherService = ref.read(teacherServiceProvider);
      _groups = await teacherService.getGroups();
      if (_groups.isNotEmpty && _selectedGroup == null) {
        _selectedGroup = _groups.first;
        await _loadStudents();
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

  Future<void> _loadStudents() async {
    if (_selectedGroup == null) return;
    try {
      final teacherService = ref.read(teacherServiceProvider);
      _students = await teacherService.getStudentsInGroup(_selectedGroup!.id);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar alumnos: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddStudentDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Agregar Alumno', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBrown)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Código del grupo: ${_selectedGroup?.code ?? ''}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'El alumno usará este código + su nombre para entrar.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty && _selectedGroup != null) {
                  Navigator.pop(context);
                  try {
                    final teacherService = ref.read(teacherServiceProvider);
                    await teacherService.addStudentToGroup(
                      _selectedGroup!.id,
                      _nameController.text.trim(),
                    );
                    await _loadStudents();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Alumno agregado'),
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddGroupDialog() {
    final TextEditingController groupController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Crear Nuevo Grupo', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBrown)),
          content: TextField(
            controller: groupController,
            decoration: InputDecoration(
              labelText: 'Nombre del grupo (ej. 5B)',
              prefixIcon: const Icon(Icons.class_),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (groupController.text.isNotEmpty) {
                  Navigator.pop(context);
                  try {
                    final teacherService = ref.read(teacherServiceProvider);
                    final newGroup = await teacherService.createGroup(groupController.text.trim());
                    _selectedGroup = newGroup;
                    await _loadGroups();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B9BF4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Crear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // IMPORTACIÓN MASIVA DE ALUMNOS
  // ═══════════════════════════════════════════════════════════════════
  void _showBulkImportDialog() {
    final TextEditingController bulkController = TextEditingController();
    int detectedCount = 0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFDF8F5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Text('📋', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text('Importar Lista de Alumnos',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBrown,
                            fontSize: 18)),
                  ),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pega los nombres de tus alumnos separados por comas, saltos de línea o punto y coma.',
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grupo destino: ${_selectedGroup?.name ?? ""}',
                      style: const TextStyle(
                          color: Color(0xFF2B9BF4),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    // Campo de texto multilínea
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: TextField(
                        controller: bulkController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText:
                              'Juan Pérez\nAna López\nCarlos Méndez\nSofía Ramírez',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onChanged: (text) {
                          final names = _parseNames(text);
                          setDialogState(() => detectedCount = names.length);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Contador de nombres detectados
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: detectedCount > 0
                            ? const Color(0xFFD5F5E3)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            detectedCount > 0 ? Icons.people : Icons.person_off,
                            color: detectedCount > 0
                                ? const Color(0xFF1E8449)
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            detectedCount > 0
                                ? '$detectedCount nombre${detectedCount > 1 ? 's' : ''} detectado${detectedCount > 1 ? 's' : ''}'
                                : 'Ningún nombre detectado',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: detectedCount > 0
                                  ? const Color(0xFF1E8449)
                                  : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  onPressed: detectedCount > 0
                      ? () async {
                          if (_selectedGroup == null) return;
                          final names = _parseNames(bulkController.text);
                          Navigator.pop(dialogContext);
                          
                          int generated = 0;
                          final teacherService = ref.read(teacherServiceProvider);
                          for (var name in names) {
                            try {
                              await teacherService.addStudentToGroup(_selectedGroup!.id, name);
                              generated++;
                            } catch (_) {}
                          }
                          await _loadStudents();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Text('✅', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Se generaron $generated alumnos para ${_selectedGroup!.name}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF27AE60),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  label: const Text('Generar Alumnos',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Parsea un texto con nombres separados por comas, saltos de línea o punto y coma.
  List<String> _parseNames(String text) {
    return text
        .split(RegExp(r'[,;\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _deleteStudent(UserModel student) async {
    if (_selectedGroup == null) return;
    try {
      final teacherService = ref.read(teacherServiceProvider);
      await teacherService.removeStudentFromGroup(_selectedGroup!.id, student.id);
      await _loadStudents();
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón de importación masiva
          FloatingActionButton.small(
            heroTag: 'bulk_import',
            onPressed: _showBulkImportDialog,
            backgroundColor: const Color(0xFF2B9BF4),
            child: const Icon(Icons.playlist_add, color: Colors.white),
          ),
          const SizedBox(height: 12),
          // Botón de agregar alumno individual
          FloatingActionButton.extended(
            heroTag: 'add_student',
            onPressed: _showAddStudentDialog,
            backgroundColor: const Color(0xFF27AE60),
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Agregar Alumno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                                'Gestión de Grupos',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppColors.textBrown,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Administra tus grupos y alumnos.',
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

                  // Group Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGroup?.id,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textDark),
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedGroup = _groups.firstWhere((g) => g.id == newValue);
                                    });
                                    _loadStudents();
                                  }
                                },
                                items: _groups.map<DropdownMenuItem<String>>((GroupModel group) {
                                  return DropdownMenuItem<String>(
                                    value: group.id,
                                    child: Text('${group.name} (${group.code})'),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: _showAddGroupDialog,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B9BF4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2B9BF4), width: 2),
                            ),
                            child: const Icon(Icons.group_add, color: Color(0xFF2B9BF4)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Student count pill
                  if (_students.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5F5E3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people, color: Color(0xFF1E8449), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${_students.length} alumno${_students.length > 1 ? 's' : ''} en ${_selectedGroup?.name ?? ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E8449),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Student List
                  Expanded(
                    child: _students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay alumnos en este grupo',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _showBulkImportDialog,
                                  icon: const Icon(Icons.playlist_add, color: Color(0xFF2B9BF4)),
                                  label: const Text('Importar lista de alumnos',
                                      style: TextStyle(
                                          color: Color(0xFF2B9BF4),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8).copyWith(bottom: 100),
                            itemCount: _students.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final student = _students[index];
                              // Asignar avatares variados según índice
                              final avatars = ['👦🏽', '👧🏻', '👦🏻', '👧🏽', '🧑🏽', '👩🏻', '👦🏼', '👧🏼'];
                              final avatar = avatars[index % avatars.length];

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade200, width: 2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDE8E1),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFE67E22), width: 2),
                                    ),
                                    child: Center(
                                      child: Text(avatar, style: const TextStyle(fontSize: 24)),
                                    ),
                                  ),
                                  title: Text(
                                    student.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nombre: ${student.name}\nGrupo: ${_selectedGroup?.code ?? ""}',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteStudent(student),
                                  ),
                                ),
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
