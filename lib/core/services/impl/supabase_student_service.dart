import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../student_service.dart';

/// Implementación del servicio de alumno con Supabase.
/// Todas las operaciones van contra la BD en la nube.
class SupabaseStudentService implements StudentService {
  final _client = Supabase.instance.client;
  String? _studentId;

  /// Establecer el ID del alumno actual (se llama después del login).
  void setStudentId(String id) => _studentId = id;

  String get _sid {
    if (_studentId == null) throw Exception('StudentId no configurado. Haz login primero.');
    return _studentId!;
  }

  // ── Niveles ──────────────────────────────────────────────────────────
  @override
  Future<List<LevelModel>> getLevels() async {
    final result = await _client
        .from('levels')
        .select()
        .eq('is_active', true)
        .order('order_index');

    // Obtener progreso del alumno para saber cuáles están desbloqueados
    final progress = await getLevelStars();

    return result.map((json) {
      final level = LevelModel.fromJson(json);
      // El nivel 0 siempre desbloqueado, los demás si completaste el anterior
      final isUnlocked = level.id == 0 ||
          (progress.containsKey((level.id - 1).toString()) &&
           (progress[(level.id - 1).toString()] ?? 0) > 0);
      return level.copyWith(isUnlocked: isUnlocked);
    }).toList();
  }

  @override
  Future<void> unlockLevel(int levelId) async {
    // Los niveles se desbloquean automáticamente al completar el anterior
    // No necesita acción explícita con la BD
  }

  // ── Preguntas ────────────────────────────────────────────────────────
  @override
  Future<List<QuestionModel>> getQuestionsForLevel(int levelId) async {
    final result = await _client
        .from('questions')
        .select()
        .eq('level_id', levelId);

    return result.map((json) {
      // Supabase guarda options como JSONB, convertirlo a List<String>
      final options = json['options'];
      final List<String> optionsList = options is List
          ? options.map((e) => e.toString()).toList()
          : <String>[];

      return QuestionModel(
        id: json['id'],
        levelId: json['level_id'],
        questionText: json['question_text'] ?? '',
        imageUrl: json['image_url'] ?? '',
        options: optionsList,
        correctIndex: json['correct_index'] ?? 0,
        hint: json['hint'] ?? '',
        funFact: json['fun_fact'] ?? '',
      );
    }).toList();
  }

  // ── Progreso / Estrellas ─────────────────────────────────────────────
  @override
  Future<void> saveStars(int levelId, int starsEarned) async {
    // Upsert: insertar o actualizar si ya existe
    await _client.from('student_progress').upsert({
      'student_id': _sid,
      'level_id': levelId,
      'stars_earned': starsEarned,
      'is_completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'student_id,level_id');
  }

  @override
  Future<int> getTotalStars() async {
    final stars = await getLevelStars();
    final earned = stars.values.fold(0, (sum, s) => sum + s);

    // Restar estrellas gastadas en compras
    final purchases = await _client
        .from('purchased_rewards')
        .select('reward_id, rewards!inner(cost)')
        .eq('student_id', _sid);

    int spent = 0;
    for (final p in purchases) {
      spent += (p['rewards']['cost'] as int?) ?? 0;
    }

    return earned - spent;
  }

  @override
  Future<Map<String, int>> getLevelStars() async {
    final result = await _client
        .from('student_progress')
        .select('level_id, stars_earned')
        .eq('student_id', _sid);

    final map = <String, int>{};
    for (final row in result) {
      map[row['level_id'].toString()] = row['stars_earned'] as int;
    }
    return map;
  }

  // ── Corazones ────────────────────────────────────────────────────────
  @override
  Future<int> getHearts() async {
    final result = await _client
        .from('profiles')
        .select('hearts')
        .eq('id', _sid)
        .single();
    return result['hearts'] as int? ?? 5;
  }

  @override
  Future<void> deductHeart() async {
    final current = await getHearts();
    if (current > 0) {
      await _client
          .from('profiles')
          .update({'hearts': current - 1})
          .eq('id', _sid);
    }
  }

  @override
  Future<void> restoreHearts() async {
    await _client
        .from('profiles')
        .update({'hearts': 5})
        .eq('id', _sid);
  }

  // ── Recompensas ──────────────────────────────────────────────────────
  @override
  Future<List<RewardModel>> getAvailableRewards() async {
    // Buscar el grupo del alumno
    final membership = await _client
        .from('group_members')
        .select('group_id')
        .eq('student_id', _sid)
        .limit(1)
        .maybeSingle();

    if (membership == null) return [];

    final groupId = membership['group_id'];
    final result = await _client
        .from('rewards')
        .select()
        .eq('group_id', groupId);

    return result.map((json) => RewardModel.fromJson(json)).toList();
  }

  @override
  Future<bool> purchaseReward(String rewardId, int cost) async {
    final totalStars = await getTotalStars();
    if (totalStars < cost) return false;
    if (await isRewardPurchased(rewardId)) return false;

    await _client.from('purchased_rewards').insert({
      'student_id': _sid,
      'reward_id': rewardId,
    });

    return true;
  }

  @override
  Future<bool> isRewardPurchased(String rewardId) async {
    final result = await _client
        .from('purchased_rewards')
        .select('id')
        .eq('student_id', _sid)
        .eq('reward_id', rewardId)
        .maybeSingle();
    return result != null;
  }

  @override
  Future<List<String>> getPurchasedRewardIds() async {
    final result = await _client
        .from('purchased_rewards')
        .select('reward_id')
        .eq('student_id', _sid);
    return result.map<String>((r) => r['reward_id'] as String).toList();
  }

  // ── Enciclopedia ─────────────────────────────────────────────────────
  @override
  Future<List<int>> getUnlockedCardIds() async {
    final result = await _client
        .from('unlocked_cards')
        .select('card_id')
        .eq('student_id', _sid);
    return result.map<int>((r) => r['card_id'] as int).toList();
  }

  @override
  Future<void> unlockCard(int cardId) async {
    await _client.from('unlocked_cards').upsert({
      'student_id': _sid,
      'card_id': cardId,
    }, onConflict: 'student_id,card_id');
  }

  // ── Intentos ─────────────────────────────────────────────────────────
  @override
  Future<void> recordAttempt(QuizAttemptModel attempt) async {
    await _client.from('quiz_attempts').insert({
      'student_id': _sid,
      'question_id': attempt.questionId,
      'selected_index': attempt.selectedIndex,
      'is_correct': attempt.isCorrect,
      'time_seconds': attempt.timeSeconds,
    });
  }

  // ── Reset ────────────────────────────────────────────────────────────
  @override
  Future<void> resetAllProgress() async {
    await _client.from('student_progress').delete().eq('student_id', _sid);
    await _client.from('purchased_rewards').delete().eq('student_id', _sid);
    await _client.from('unlocked_cards').delete().eq('student_id', _sid);
    await _client.from('quiz_attempts').delete().eq('student_id', _sid);
    await restoreHearts();
  }
}
