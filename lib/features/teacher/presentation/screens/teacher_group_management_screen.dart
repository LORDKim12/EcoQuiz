import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../student/domain/models/game_state.dart';

class TeacherGroupManagementScreen extends StatefulWidget {
  const TeacherGroupManagementScreen({super.key});

  @override
  State<TeacherGroupManagementScreen> createState() => _TeacherGroupManagementScreenState();
}

class _TeacherGroupManagementScreenState extends State<TeacherGroupManagementScreen> {
  String _selectedGroup = 'Grupo 4A';
  final List<String> _groups = ['Grupo 4A', 'Grupo 4B', 'Grupo 5A'];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();



  void _showAddStudentDialog() {
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
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuario de acceso',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'La contraseña temporal será "eco123" y se pedirá cambiarla al iniciar sesión.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _usernameController.text.isNotEmpty) {
                  context.read<GameState>().addStudentsInBulk(
                    [_nameController.text.trim()],
                    _selectedGroup,
                  );
                  _nameController.clear();
                  _usernameController.clear();
                  Navigator.pop(context);
                  setState(() {}); // Refresh list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alumno agregado exitosamente')),
                  );
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
              onPressed: () {
                if (groupController.text.isNotEmpty) {
                  setState(() {
                    _groups.add(groupController.text.trim());
                    _selectedGroup = groupController.text.trim();
                  });
                  Navigator.pop(context);
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
                      'Grupo destino: $_selectedGroup',
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
                      ? () {
                          final names = _parseNames(bulkController.text);
                          final generated = context.read<GameState>()
                              .addStudentsInBulk(names, _selectedGroup);
                          Navigator.pop(dialogContext);
                          setState(() {}); // Refresh student list

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Text('✅', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Se generaron ${generated.length} alumnos para $_selectedGroup',
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

  @override
  Widget build(BuildContext context) {
    final studentList = context.watch<GameState>().getStudentsForGroup(_selectedGroup);

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
                          value: _selectedGroup,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textDark),
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedGroup = newValue);
                            }
                          },
                          items: _groups.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón de importar lista
                  InkWell(
                    onTap: _showBulkImportDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF39C12).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF39C12), width: 2),
                      ),
                      child: const Icon(Icons.playlist_add, color: Color(0xFFF39C12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _showAddGroupDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B9BF4).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2B9BF4), width: 2),
                      ),
                      child: const Icon(Icons.group_add, color: Color(0xFF2B9BF4)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Student count pill
            if (studentList.isNotEmpty)
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
                        '${studentList.length} alumno${studentList.length > 1 ? 's' : ''} en $_selectedGroup',
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
              child: studentList.isEmpty
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
                      itemCount: studentList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = studentList[index];
                        // Asignar avatares variados según índice
                        final avatars = ['👦🏽', '👧🏻', '👦🏻', '👧🏽', '🧑🏽', '👩🏻', '👦🏼', '👧🏼'];
                        final avatar = avatars[index % avatars.length];

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
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
                                  'Usuario: ${student.username}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                                Text(
                                  'Contraseña: ${student.password}',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                context.read<GameState>().removeStudent(student.username);
                                setState(() {});
                              },
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
