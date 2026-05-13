import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TeacherGroupManagementScreen extends StatefulWidget {
  const TeacherGroupManagementScreen({super.key});

  @override
  State<TeacherGroupManagementScreen> createState() => _TeacherGroupManagementScreenState();
}

class _TeacherGroupManagementScreenState extends State<TeacherGroupManagementScreen> {
  // Datos simulados para la UI
  String _selectedGroup = 'Grupo 4A';
  final List<String> _groups = ['Grupo 4A', 'Grupo 4B', 'Grupo 5A'];

  final List<Map<String, String>> _students = [
    {'name': 'Juan Pérez', 'username': 'juan.perez4A', 'avatar': '👦🏽'},
    {'name': 'Ana López', 'username': 'ana.lopez4A', 'avatar': '👧🏻'},
    {'name': 'Carlos Méndez', 'username': 'carlos.m4A', 'avatar': '👦🏻'},
    {'name': 'Sofía Ramírez', 'username': 'sofia.r4A', 'avatar': '👧🏽'},
  ];

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
                  setState(() {
                    _students.add({
                      'name': _nameController.text.trim(),
                      'username': _usernameController.text.trim(),
                      'avatar': '🧑🏽', // Default avatar
                    });
                  });
                  _nameController.clear();
                  _usernameController.clear();
                  Navigator.pop(context);
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
                    _students.clear(); // Limpiar alumnos simulados para el nuevo grupo
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        backgroundColor: const Color(0xFF27AE60),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Agregar Alumno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                            color: AppColors.textDark.withOpacity(0.8),
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
                              setState(() {
                                _selectedGroup = newValue;
                                // En una app real, aquí cargaríamos los alumnos de la BD
                              });
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
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8).copyWith(bottom: 80),
                      itemCount: _students.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = _students[index];
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
                                child: Text(student['avatar']!, style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                            title: Text(
                              student['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16),
                            ),
                            subtitle: Text(
                              'Usuario: ${student['username']}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _students.removeAt(index);
                                    });
                                  },
                                ),
                              ],
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
