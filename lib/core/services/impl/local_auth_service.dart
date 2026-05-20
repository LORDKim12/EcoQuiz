import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../auth_service.dart';

/// Implementación local de autenticación para la demo.
/// Guarda el usuario en SharedPreferences. Sin validación real.
class LocalAuthService implements AuthService {
  static const _keyUserId = 'auth_user_id';
  static const _keyUserName = 'auth_user_name';
  static const _keyUserRole = 'auth_user_role';

  UserModel? _currentUser;

  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    if (id == null) return null;

    _currentUser = UserModel(
      id: id,
      name: prefs.getString(_keyUserName) ?? 'Explorador',
      role: prefs.getString(_keyUserRole) == 'teacher'
          ? UserRole.teacher
          : UserRole.student,
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  @override
  Future<UserModel> loginStudent({
    required String groupCode,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // En la demo, generamos un ID simple basado en el nombre
    final id = 'student_${name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

    _currentUser = UserModel(
      id: id,
      name: name.isEmpty ? 'Explorador' : name,
      role: UserRole.student,
      createdAt: DateTime.now(),
    );

    await prefs.setString(_keyUserId, _currentUser!.id);
    await prefs.setString(_keyUserName, _currentUser!.name);
    await prefs.setString(_keyUserRole, 'student');

    return _currentUser!;
  }

  @override
  Future<UserModel> loginTeacher({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // En la demo, cualquier PIN "1234" funciona
    _currentUser = UserModel(
      id: 'teacher_demo',
      name: 'Profesor Demo',
      email: email,
      role: UserRole.teacher,
      createdAt: DateTime.now(),
    );

    await prefs.setString(_keyUserId, _currentUser!.id);
    await prefs.setString(_keyUserName, _currentUser!.name);
    await prefs.setString(_keyUserRole, 'teacher');

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserRole);
    _currentUser = null;
  }
}
