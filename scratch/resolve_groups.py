import re

with open('c:/Antigraity/Flutter/EcoQuiz/lib/features/teacher/presentation/screens/teacher_group_management_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Resolve 1: Imports
content = re.sub(
r'<<<<<<< HEAD\nimport \'package:provider/provider.dart\';\nimport \'../../../student/domain/models/game_state.dart\';\n=======\nimport \'../../../../core/providers/service_providers.dart\';\nimport \'../../../../core/models/models.dart\';\n>>>>>>> 8628a3d250a3cb5fdec446109adc2b8ae3741257',
'''import 'package:provider/provider.dart';
import '../../../student/domain/models/game_state.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/models/models.dart';''', content)

# Resolve 2: State vars
content = re.sub(
r'<<<<<<< HEAD\nclass _TeacherGroupManagementScreenState extends State<TeacherGroupManagementScreen> \{\n  String _selectedGroup = \'Grupo 4A\';\n  final List<String> _groups = \[\'Grupo 4A\', \'Grupo 4B\', \'Grupo 5A\'\];\n=======\nclass _TeacherGroupManagementScreenState extends ConsumerState<TeacherGroupManagementScreen> \{\n  List<GroupModel> _groups = \[\];\n  List<UserModel> _students = \[\];\n  GroupModel\? _selectedGroup;\n  bool _isLoading = true;\n>>>>>>> 8628a3d250a3cb5fdec446109adc2b8ae3741257',
'''class _TeacherGroupManagementScreenState extends ConsumerState<TeacherGroupManagementScreen> {
  List<GroupModel> _groups = [];
  List<UserModel> _students = [];
  GroupModel? _selectedGroup;
  bool _isLoading = true;''', content)

# Resolve 3: Add Student onPressed
content = re.sub(
r'<<<<<<< HEAD\n              onPressed: \(\) \{\n                if \(_nameController\.text\.isNotEmpty && _usernameController\.text\.isNotEmpty\) \{\n                  context\.read<GameState>\(\)\.addStudentsInBulk\(\n                    \[_nameController\.text\.trim\(\)\],\n                    _selectedGroup,\n                  \);\n                  _nameController\.clear\(\);\n                  _usernameController\.clear\(\);\n                  Navigator\.pop\(context\);\n                  setState\(\(\) \{\}\); // Refresh list\n                  ScaffoldMessenger\.of\(context\)\.showSnackBar\(\n                    const SnackBar\(content: Text\(\'Alumno agregado exitosamente\'\)\),\n                  \);\n=======\n              onPressed: \(\) async \{\n                if \(_nameController\.text\.isNotEmpty && _selectedGroup != null\) \{\n                  Navigator\.pop\(context\);\n                  try \{\n                    final teacherService = ref\.read\(teacherServiceProvider\);\n                    await teacherService\.addStudentToGroup\(\n                      _selectedGroup!\.id,\n                      _nameController\.text\.trim\(\),\n                    \);\n                    await _loadStudents\(\);\n                    if \(mounted\) \{\n                      ScaffoldMessenger\.of\(context\)\.showSnackBar\(\n                        const SnackBar\(\n                          content: Text\('✅ Alumno agregado'\),\n                          backgroundColor: Colors\.green,\n                        \),\n                      \);\n                    \}\n                  \} catch \(e\) \{\n                    if \(mounted\) \{\n                      ScaffoldMessenger\.of\(context\)\.showSnackBar\(\n                        SnackBar\(content: Text\('Error: \$e'\), backgroundColor: Colors\.red\),\n                      \);\n                    \}\n                  \}\n>>>>>>> 8628a3d250a3cb5fdec446109adc2b8ae3741257',
'''              onPressed: () async {
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
                  }''', content)

# Resolve 4: Add Group Dialog
content = re.sub(
r'<<<<<<< HEAD\n                  setState\(\(\) \{\n                    _groups\.add\(groupController\.text\.trim\(\)\);\n                    _selectedGroup = groupController\.text\.trim\(\);\n                  \}\);\n=======\n>>>>>>> 8628a3d250a3cb5fdec446109adc2b8ae3741257',
''' ''', content)

# Resolve 5: The Bulk Import / Delete block
# The conflict starts at `<<<<<<< HEAD` (line 233)
# and ends at `>>>>>>> 8628...` (line 429)
# Wait, this block contains BOTH the bulk import dialog AND the delete student logic.
# I will just write the block out explicitly using a basic string replace for the conflict markers since it's huge.

with open('c:/Antigraity/Flutter/EcoQuiz/lib/features/teacher/presentation/screens/teacher_group_management_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
