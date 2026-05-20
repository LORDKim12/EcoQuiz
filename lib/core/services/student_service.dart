import '../models/models.dart';

/// Interfaz para todas las operaciones del alumno.
/// Implementaciones: LocalStudentService (demo), SupabaseStudentService (prod)
abstract class StudentService {
  // ── Niveles ──────────────────────────────────────────────────────────
  /// Obtener la lista de niveles disponibles para el alumno.
  Future<List<LevelModel>> getLevels();

  /// Desbloquear un nivel.
  Future<void> unlockLevel(int levelId);

  // ── Preguntas ────────────────────────────────────────────────────────
  /// Obtener las preguntas de un nivel específico.
  Future<List<QuestionModel>> getQuestionsForLevel(int levelId);

  // ── Progreso / Estrellas ─────────────────────────────────────────────
  /// Guardar estrellas ganadas en un nivel (solo si supera el récord).
  Future<void> saveStars(int levelId, int starsEarned);

  /// Obtener el total de estrellas disponibles (ganadas - gastadas).
  Future<int> getTotalStars();

  /// Obtener el mapa de estrellas por nivel.
  Future<Map<String, int>> getLevelStars();

  // ── Corazones ────────────────────────────────────────────────────────
  /// Obtener los corazones actuales.
  Future<int> getHearts();

  /// Restar un corazón.
  Future<void> deductHeart();

  /// Restaurar todos los corazones a 5.
  Future<void> restoreHearts();

  // ── Recompensas ──────────────────────────────────────────────────────
  /// Obtener las recompensas disponibles para comprar.
  Future<List<RewardModel>> getAvailableRewards();

  /// Comprar una recompensa gastando estrellas. Retorna true si exitoso.
  Future<bool> purchaseReward(String rewardId, int cost);

  /// Verificar si una recompensa ya fue comprada.
  Future<bool> isRewardPurchased(String rewardId);

  /// Obtener los IDs de recompensas compradas.
  Future<List<String>> getPurchasedRewardIds();

  // ── Enciclopedia ─────────────────────────────────────────────────────
  /// Obtener las tarjetas desbloqueadas.
  Future<List<int>> getUnlockedCardIds();

  /// Desbloquear una tarjeta.
  Future<void> unlockCard(int cardId);

  // ── Intentos de Quiz (analytics) ────────────────────────────────────
  /// Registrar un intento de respuesta.
  Future<void> recordAttempt(QuizAttemptModel attempt);

  // ── Reset ────────────────────────────────────────────────────────────
  /// Reiniciar todo el progreso del alumno.
  Future<void> resetAllProgress();
}
