import '../models/models.dart';

/// Interfaz para todas las operaciones del maestro.
/// Implementaciones: LocalTeacherService (demo), SupabaseTeacherService (prod)
abstract class TeacherService {
  // ── Grupos ───────────────────────────────────────────────────────────
  /// Obtener los grupos del maestro.
  Future<List<GroupModel>> getGroups();

  /// Crear un nuevo grupo.
  Future<GroupModel> createGroup(String name);

  /// Obtener los alumnos de un grupo.
  Future<List<UserModel>> getStudentsInGroup(String groupId);

  /// Agregar un alumno a un grupo.
  Future<void> addStudentToGroup(String groupId, String studentName);

  /// Eliminar un alumno de un grupo.
  Future<void> removeStudentFromGroup(String groupId, String studentId);

  // ── Niveles ──────────────────────────────────────────────────────────
  /// Obtener todos los niveles (para administrar).
  Future<List<LevelModel>> getLevels();

  /// Agregar un nivel nuevo.
  Future<void> addLevel(String title);

  /// Cambiar el estado de un nivel (bloqueado/desbloqueado).
  Future<void> setLevelActive(int levelId, bool isActive);

  // ── Recompensas ──────────────────────────────────────────────────────
  /// Obtener las recompensas del grupo.
  Future<List<RewardModel>> getRewards({String? groupId});

  /// Agregar una recompensa.
  Future<void> addReward(RewardModel reward);

  /// Eliminar una recompensa.
  Future<void> removeReward(String rewardId);

  // ── Progreso / Analytics ─────────────────────────────────────────────
  /// Obtener el progreso de todos los alumnos de un grupo.
  Future<Map<String, Map<String, int>>> getGroupProgress(String groupId);

  /// Obtener estadísticas generales del grupo.
  Future<Map<String, dynamic>> getGroupStats(String groupId);

  /// Obtener los intentos de quiz de un alumno.
  Future<List<QuizAttemptModel>> getStudentAttempts(String studentId);
}
