import '../models/user_model.dart';

/// Interfaz de autenticación.
/// Implementaciones: LocalAuthService (demo), SupabaseAuthService (producción)
abstract class AuthService {
  /// Obtener el usuario actualmente logueado, o null si no hay sesión.
  Future<UserModel?> getCurrentUser();

  /// Login de alumno: busca el grupo por código y registra al alumno por nombre.
  /// Retorna el usuario creado/encontrado.
  Future<UserModel> loginStudent({
    required String groupCode,
    required String name,
  });

  /// Login de maestro con credenciales.
  Future<UserModel> loginTeacher({
    required String email,
    required String password,
  });

  /// Cerrar sesión.
  Future<void> logout();

  /// ¿Hay un usuario logueado?
  bool get isLoggedIn;
}
