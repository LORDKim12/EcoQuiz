import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/impl/supabase_auth_service.dart';
import '../services/impl/supabase_student_service.dart';
import '../services/impl/supabase_teacher_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// PROVIDERS DE SERVICIOS — SUPABASE
//
// Para volver a demo local, cambia las implementaciones:
//   SupabaseAuthService()    → LocalAuthService()
//   SupabaseStudentService() → LocalStudentService()
//   SupabaseTeacherService() → LocalTeacherService()
// ═══════════════════════════════════════════════════════════════════════════════

/// Provider de autenticación.
final authServiceProvider = Provider<AuthService>((ref) {
  return SupabaseAuthService();
});

/// Provider del servicio de alumno.
final studentServiceProvider = Provider<SupabaseStudentService>((ref) {
  return SupabaseStudentService();
});

/// Provider del servicio de maestro.
final teacherServiceProvider = Provider<SupabaseTeacherService>((ref) {
  return SupabaseTeacherService();
});
