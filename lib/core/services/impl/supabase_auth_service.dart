import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../auth_service.dart';

/// Implementación de autenticación con Supabase.
/// Maestros: email + PIN validado contra tabla profiles.
/// Alumnos: grupo + nombre (sin contraseña, auto-registro).
class SupabaseAuthService implements AuthService {
  final _client = Supabase.instance.client;
  UserModel? _currentUser;

  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  // ── Login de Alumno ───────────────────────────────────────────────
  @override
  Future<UserModel> loginStudent({
    required String groupCode,
    required String name,
  }) async {
    final trimmedName = name.trim().isEmpty ? 'Explorador' : name.trim();

    // 1. Buscar el grupo por código
    final groupResult = await _client
        .from('groups')
        .select('id')
        .eq('code', groupCode.toUpperCase())
        .maybeSingle();

    if (groupResult == null) {
      throw Exception('No existe un grupo con el código "${groupCode.toUpperCase()}"');
    }

    final groupId = groupResult['id'] as String;

    // 2. Buscar si el alumno ya existe en ese grupo
    final memberResult = await _client
        .from('group_members')
        .select('student_id, profiles!inner(id, name, role, hearts, created_at)')
        .eq('group_id', groupId)
        .limit(50);

    for (final member in memberResult) {
      final profile = member['profiles'];
      if (profile != null &&
          (profile['name'] as String).toLowerCase() == trimmedName.toLowerCase()) {
        _currentUser = UserModel(
          id: profile['id'],
          name: profile['name'],
          role: UserRole.student,
          createdAt: DateTime.tryParse(profile['created_at'] ?? '') ?? DateTime.now(),
        );
        return _currentUser!;
      }
    }

    throw Exception('No existe el alumno "$trimmedName" en el grupo ${groupCode.toUpperCase()}');
  }

  // ── Login de Maestro ──────────────────────────────────────────────
  @override
  Future<UserModel> loginTeacher({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPin = password.trim();

    if (trimmedEmail.isEmpty) {
      throw Exception('Ingresa tu correo electrónico');
    }
    if (trimmedPin.isEmpty) {
      throw Exception('Ingresa tu PIN');
    }

    // Buscar maestro por email
    final result = await _client
        .from('profiles')
        .select()
        .eq('role', 'teacher')
        .eq('email', trimmedEmail)
        .maybeSingle();

    if (result == null) {
      throw Exception('No existe una cuenta de maestro con ese correo');
    }

    // Validar PIN
    final storedPin = result['pin'] as String?;
    if (storedPin == null || storedPin.isEmpty) {
      throw Exception('Esta cuenta no tiene PIN configurado. Contacta al administrador.');
    }

    if (storedPin != trimmedPin) {
      throw Exception('PIN incorrecto');
    }

    _currentUser = UserModel(
      id: result['id'],
      name: result['name'],
      email: trimmedEmail,
      role: UserRole.teacher,
      createdAt: DateTime.tryParse(result['created_at'] ?? '') ?? DateTime.now(),
    );

    return _currentUser!;
  }

  // ── Registro de Maestro (para crear cuentas nuevas) ──────────────
  Future<UserModel> registerTeacher({
    required String name,
    required String email,
    required String pin,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    // Verificar que no exista ya
    final existing = await _client
        .from('profiles')
        .select('id')
        .eq('email', trimmedEmail)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Ya existe una cuenta con ese correo');
    }

    final result = await _client.from('profiles').insert({
      'name': name.trim(),
      'email': trimmedEmail,
      'role': 'teacher',
      'pin': pin,
      'hearts': 5,
    }).select().single();

    return UserModel(
      id: result['id'],
      name: result['name'],
      email: trimmedEmail,
      role: UserRole.teacher,
      createdAt: DateTime.now(),
    );
  }

  // ── Cambiar PIN ──────────────────────────────────────────────────
  Future<void> changePin({
    required String userId,
    required String currentPin,
    required String newPin,
  }) async {
    // Verificar PIN actual
    final result = await _client
        .from('profiles')
        .select('pin')
        .eq('id', userId)
        .single();

    if (result['pin'] != currentPin) {
      throw Exception('PIN actual incorrecto');
    }

    await _client
        .from('profiles')
        .update({'pin': newPin})
        .eq('id', userId);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}
