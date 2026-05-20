import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../student_service.dart';

/// Implementación local del servicio de alumno.
/// Envuelve SharedPreferences manteniendo la funcionalidad actual de GameState.
class LocalStudentService implements StudentService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Niveles ──────────────────────────────────────────────────────────
  @override
  Future<List<LevelModel>> getLevels() async {
    final prefs = await _getPrefs();
    final json = prefs.getString('dynamic_levels');
    if (json != null) {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((e) => LevelModel.fromJson(e)).toList();
    }
    // Defaults
    return [
      const LevelModel(id: 0, title: 'Ciudad', biome: 'ciudad', orderIndex: 0, isUnlocked: true),
      const LevelModel(id: 1, title: 'Manglar', biome: 'manglar', orderIndex: 1),
      const LevelModel(id: 2, title: 'Arrecife', biome: 'arrecife', orderIndex: 2),
      const LevelModel(id: 3, title: 'Bosque', biome: 'bosque', orderIndex: 3),
      const LevelModel(id: 4, title: 'Selva', biome: 'selva', orderIndex: 4),
      const LevelModel(id: 5, title: 'Desierto', biome: 'desierto', orderIndex: 5),
    ];
  }

  @override
  Future<void> unlockLevel(int levelId) async {
    final prefs = await _getPrefs();
    final levels = await getLevels();
    final updated = levels.map((l) {
      if (l.id == levelId) return l.copyWith(isUnlocked: true);
      return l;
    }).toList();
    await prefs.setString(
      'dynamic_levels',
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  // ── Preguntas ────────────────────────────────────────────────────────
  @override
  Future<List<QuestionModel>> getQuestionsForLevel(int levelId) async {
    // En local, usamos el QuestionBank existente convertido a QuestionModel.
    // Cuando se integre la BD, este método hará un query a la tabla 'questions'.
    // Por ahora retornamos vacío — el QuestionBank legacy sigue funcionando
    // en las pantallas hasta que se complete la migración.
    return [];
  }

  // ── Progreso / Estrellas ─────────────────────────────────────────────
  @override
  Future<void> saveStars(int levelId, int starsEarned) async {
    final prefs = await _getPrefs();
    final starsMap = await getLevelStars();
    final current = starsMap[levelId.toString()] ?? 0;
    if (starsEarned > current) {
      starsMap[levelId.toString()] = starsEarned;
      await prefs.setString('level_stars', jsonEncode(starsMap));
    }
  }

  @override
  Future<int> getTotalStars() async {
    final starsMap = await getLevelStars();
    final prefs = await _getPrefs();
    final earned = starsMap.values.fold(0, (sum, s) => sum + s);
    final spent = prefs.getInt('spent_stars') ?? 0;
    return earned - spent;
  }

  @override
  Future<Map<String, int>> getLevelStars() async {
    final prefs = await _getPrefs();
    final json = prefs.getString('level_stars');
    if (json != null) {
      final Map<String, dynamic> decoded = jsonDecode(json);
      return decoded.map((k, v) => MapEntry(k, v as int));
    }
    return {};
  }

  // ── Corazones ────────────────────────────────────────────────────────
  @override
  Future<int> getHearts() async {
    final prefs = await _getPrefs();
    return prefs.getInt('hearts') ?? 5;
  }

  @override
  Future<void> deductHeart() async {
    final prefs = await _getPrefs();
    final current = prefs.getInt('hearts') ?? 5;
    if (current > 0) {
      await prefs.setInt('hearts', current - 1);
    }
  }

  @override
  Future<void> restoreHearts() async {
    final prefs = await _getPrefs();
    await prefs.setInt('hearts', 5);
  }

  // ── Recompensas ──────────────────────────────────────────────────────
  @override
  Future<List<RewardModel>> getAvailableRewards() async {
    final prefs = await _getPrefs();
    final json = prefs.getString('dynamic_rewards');
    if (json != null) {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((e) => RewardModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<bool> purchaseReward(String rewardId, int cost) async {
    final totalStars = await getTotalStars();
    if (totalStars < cost) return false;
    if (await isRewardPurchased(rewardId)) return false;

    final prefs = await _getPrefs();

    // Gastar estrellas
    final currentSpent = prefs.getInt('spent_stars') ?? 0;
    await prefs.setInt('spent_stars', currentSpent + cost);

    // Guardar compra
    final purchased = await getPurchasedRewardIds();
    purchased.add(rewardId);
    await prefs.setString('purchased_rewards', jsonEncode(purchased));

    return true;
  }

  @override
  Future<bool> isRewardPurchased(String rewardId) async {
    final purchased = await getPurchasedRewardIds();
    return purchased.contains(rewardId);
  }

  @override
  Future<List<String>> getPurchasedRewardIds() async {
    final prefs = await _getPrefs();
    final json = prefs.getString('purchased_rewards');
    if (json != null) {
      return List<String>.from(jsonDecode(json));
    }
    return [];
  }

  // ── Enciclopedia ─────────────────────────────────────────────────────
  @override
  Future<List<int>> getUnlockedCardIds() async {
    final prefs = await _getPrefs();
    final json = prefs.getString('unlocked_cards');
    if (json != null) {
      return List<int>.from(jsonDecode(json));
    }
    return [0, 4]; // Defaults
  }

  @override
  Future<void> unlockCard(int cardId) async {
    final prefs = await _getPrefs();
    final ids = await getUnlockedCardIds();
    if (!ids.contains(cardId)) {
      ids.add(cardId);
      await prefs.setString('unlocked_cards', jsonEncode(ids));
    }
  }

  // ── Intentos ─────────────────────────────────────────────────────────
  @override
  Future<void> recordAttempt(QuizAttemptModel attempt) async {
    // En local, guardamos los intentos en SharedPreferences como JSON.
    // En producción, esto se insertará en la tabla 'quiz_attempts'.
    final prefs = await _getPrefs();
    final json = prefs.getString('quiz_attempts');
    final List<dynamic> attempts = json != null ? jsonDecode(json) : [];
    attempts.add(attempt.toJson());
    await prefs.setString('quiz_attempts', jsonEncode(attempts));
  }

  // ── Reset ────────────────────────────────────────────────────────────
  @override
  Future<void> resetAllProgress() async {
    final prefs = await _getPrefs();
    await prefs.setString('unlocked_cards', '[]');
    await prefs.setString('level_stars', '{}');
    await prefs.setInt('spent_stars', 0);
    await prefs.setString('purchased_rewards', '[]');
    await prefs.setString('quiz_attempts', '[]');
    await prefs.setInt('hearts', 5);
    await prefs.setString('player_name', 'Explorador');

    // Reset levels
    final defaults = [
      const LevelModel(id: 0, title: 'Ciudad', biome: 'ciudad', orderIndex: 0, isUnlocked: true),
      const LevelModel(id: 1, title: 'Manglar', biome: 'manglar', orderIndex: 1),
      const LevelModel(id: 2, title: 'Arrecife', biome: 'arrecife', orderIndex: 2),
      const LevelModel(id: 3, title: 'Bosque', biome: 'bosque', orderIndex: 3),
      const LevelModel(id: 4, title: 'Selva', biome: 'selva', orderIndex: 4),
      const LevelModel(id: 5, title: 'Desierto', biome: 'desierto', orderIndex: 5),
    ];
    await prefs.setString(
      'dynamic_levels',
      jsonEncode(defaults.map((e) => e.toJson()).toList()),
    );
  }
}
