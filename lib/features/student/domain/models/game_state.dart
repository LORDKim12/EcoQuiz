import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EncyclopediaCardData {
  final int id;
  final String title;
  final String subtitle;
  final String imagePath;
  final String number;
  final IconData typeIcon;
  final Color themeColor;
  final bool isAnimal;
  final String biome;

  const EncyclopediaCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.number,
    required this.typeIcon,
    required this.themeColor,
    required this.isAnimal,
    required this.biome,
  });
}

/// Representa una parada dentro de una Expedición.
/// Cada parada tiene su propio set de preguntas (quiz independiente).
class ExpeditionStop {
  final int id;
  final String title;
  final List<QuizQuestion> questions;
  final bool isCompleted;

  const ExpeditionStop({
    required this.id,
    required this.title,
    this.questions = const [],
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'questions': questions.map((q) => q.toJson()).toList(),
    'isCompleted': isCompleted,
  };

  factory ExpeditionStop.fromJson(Map<String, dynamic> json) => ExpeditionStop(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    questions: json['questions'] != null
        ? (json['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList()
        : [],
    isCompleted: json['isCompleted'] ?? false,
  );

  ExpeditionStop copyWith({
    bool? isCompleted,
    String? title,
    List<QuizQuestion>? questions,
  }) => ExpeditionStop(
    id: id,
    title: title ?? this.title,
    questions: questions ?? this.questions,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

class LevelData {
  final int id;
  final String title;
  final String biome;
  final bool isUnlocked;
  final List<QuizQuestion> questions;
  final String? backgroundPath;
  final String? backgroundImagePath; // Ruta del asset del bioma para el mapa
  final List<ExpeditionStop> stops; // Lista ordenada de paradas
  final List<int> completedStops; // IDs de paradas completadas

  LevelData({
    required this.id,
    required this.title,
    this.biome = '',
    this.isUnlocked = false,
    this.questions = const [],
    this.backgroundPath,
    this.backgroundImagePath,
    this.stops = const [],
    this.completedStops = const [],
  });

  /// Devuelve true si esta expedición tiene paradas configuradas.
  bool get hasStops => stops.isNotEmpty;

  /// Devuelve el índice de la parada actual (primera no completada).
  int get currentStopIndex {
    for (int i = 0; i < stops.length; i++) {
      if (!completedStops.contains(stops[i].id)) return i;
    }
    return stops.length - 1; // Todas completadas → última
  }

  /// Devuelve true si todas las paradas están completadas.
  bool get allStopsCompleted =>
      hasStops && completedStops.length >= stops.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'biome': biome,
    'isUnlocked': isUnlocked,
    'questions': questions.map((q) => q.toJson()).toList(),
    'backgroundPath': backgroundPath,
    'backgroundImagePath': backgroundImagePath,
    'stops': stops.map((s) => s.toJson()).toList(),
    'completedStops': completedStops,
  };

  factory LevelData.fromJson(Map<String, dynamic> json) => LevelData(
    id: json['id'],
    title: json['title'],
    biome: json['biome'] ?? json['title'], // Retrocompatibilidad
    isUnlocked: json['isUnlocked'] ?? false,
    questions: json['questions'] != null
        ? (json['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList()
        : [],
    backgroundPath: json['backgroundPath'],
    backgroundImagePath: json['backgroundImagePath'],
    stops: json['stops'] != null
        ? (json['stops'] as List)
              .map((s) => ExpeditionStop.fromJson(s))
              .toList()
        : [],
    completedStops: json['completedStops'] != null
        ? List<int>.from(json['completedStops'])
        : [],
  );

  LevelData copyWith({
    int? id,
    bool? isUnlocked,
    String? title,
    String? biome,
    List<QuizQuestion>? questions,
    String? backgroundPath,
    String? backgroundImagePath,
    List<ExpeditionStop>? stops,
    List<int>? completedStops,
  }) => LevelData(
    id: id ?? this.id,
    title: title ?? this.title,
    biome: biome ?? this.biome,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    questions: questions ?? this.questions,
    backgroundPath: backgroundPath ?? this.backgroundPath,
    backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
    stops: stops ?? this.stops,
    completedStops: completedStops ?? this.completedStops,
  );
}

class RewardData {
  final String id;
  final String title;
  final String subtitle;
  final int cost;
  final int colorValue;
  final int iconCodePoint;

  RewardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.cost,
    required this.colorValue,
    required this.iconCodePoint,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'cost': cost,
    'colorValue': colorValue,
    'iconCodePoint': iconCodePoint,
  };

  factory RewardData.fromJson(Map<String, dynamic> json) => RewardData(
    id: json['id'],
    title: json['title'],
    subtitle: json['subtitle'],
    cost: json['cost'],
    colorValue: json['colorValue'],
    iconCodePoint: json['iconCodePoint'],
  );
}

class StudentData {
  final String name;
  final String username;
  final String password;
  final String groupId;

  StudentData({
    required this.name,
    required this.username,
    required this.password,
    required this.groupId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'password': password,
    'groupId': groupId,
  };

  factory StudentData.fromJson(Map<String, dynamic> json) => StudentData(
    name: json['name'],
    username: json['username'],
    password: json['password'],
    groupId: json['groupId'],
  );
}

class GameState extends ChangeNotifier {
  GameState();

  List<int> _unlockedCards = [0, 4];
  List<int> get unlockedCards => _unlockedCards;

  int _hearts = 5;
  int get hearts => _hearts;

  Timer? _heartRegenTimer;
  DateTime? _nextHeartRegenTime;

  int get secondsUntilNextHeart {
    if (_hearts >= 5 || _nextHeartRegenTime == null) return 0;
    final diff = _nextHeartRegenTime!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  Future<void> _syncHeartsToSupabase() async {
    if (_studentId == null) return;
    try {
      _prefs?.setInt('local_hearts', _hearts);
      await Supabase.instance.client
          .from('profiles')
          .update({'hearts': _hearts})
          .eq('id', _studentId!);
    } catch (_) {}
  }

  void _checkHeartRegenOffline() {
    if (_hearts >= 5) {
      _nextHeartRegenTime = null;
      _prefs?.remove('next_heart_regen_time');
      return;
    }

    if (_nextHeartRegenTime == null) {
      _startHeartRegenTimer();
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(_nextHeartRegenTime!)) {
      final diff = now.difference(_nextHeartRegenTime!);
      final periodsPassed = 1 + (diff.inMinutes ~/ 5);

      _hearts += periodsPassed;
      if (_hearts >= 5) {
        _hearts = 5;
        _nextHeartRegenTime = null;
        _prefs?.remove('next_heart_regen_time');
      } else {
        final remainderSeconds = (diff.inSeconds % 300);
        _nextHeartRegenTime = now.add(
          Duration(seconds: 300 - remainderSeconds),
        );
        _prefs?.setString(
          'next_heart_regen_time',
          _nextHeartRegenTime!.toIso8601String(),
        );
        _startHeartRegenTimer();
      }
      notifyListeners();
      _syncHeartsToSupabase();
    } else {
      _startHeartRegenTimer();
    }
  }

  void _startHeartRegenTimer() {
    _heartRegenTimer?.cancel();
    if (_nextHeartRegenTime == null) {
      _nextHeartRegenTime = DateTime.now().add(const Duration(minutes: 5));
      _prefs?.setString(
        'next_heart_regen_time',
        _nextHeartRegenTime!.toIso8601String(),
      );
    }

    _heartRegenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (_nextHeartRegenTime != null && now.isAfter(_nextHeartRegenTime!)) {
        _hearts += 1;
        if (_hearts >= 5) {
          _hearts = 5;
          _nextHeartRegenTime = null;
          _prefs?.remove('next_heart_regen_time');
          timer.cancel();
        } else {
          _nextHeartRegenTime = DateTime.now().add(const Duration(minutes: 5));
          _prefs?.setString(
            'next_heart_regen_time',
            _nextHeartRegenTime!.toIso8601String(),
          );
        }
        _syncHeartsToSupabase();
      }
      notifyListeners(); // Refresh UI to update the countdown
    });
  }

  int _xp = 0;
  int get xp => _xp;

  List<LevelData> _levels = [
    // Ciudad
    LevelData(
      id: 0,
      title: 'Nivel 1',
      biome: 'Ciudad',
      isUnlocked: true,
      backgroundImagePath: 'assets/images/biome_city.png',
    ),
    LevelData(
      id: 1,
      title: 'Nivel 2',
      biome: 'Ciudad',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_city.png',
    ),
    LevelData(
      id: 2,
      title: 'Nivel 3',
      biome: 'Ciudad',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_city.png',
    ),
    LevelData(
      id: 3,
      title: 'Nivel 4',
      biome: 'Ciudad',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_city.png',
    ),
    LevelData(
      id: 4,
      title: 'Nivel 5',
      biome: 'Ciudad',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_city.png',
    ),

    // Manglar
    LevelData(
      id: 5,
      title: 'Nivel 1',
      biome: 'Manglar',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_mangrove.png',
    ),
    LevelData(
      id: 6,
      title: 'Nivel 2',
      biome: 'Manglar',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_mangrove.png',
    ),
    LevelData(
      id: 7,
      title: 'Nivel 3',
      biome: 'Manglar',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_mangrove.png',
    ),
    LevelData(
      id: 8,
      title: 'Nivel 4',
      biome: 'Manglar',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_mangrove.png',
    ),
    LevelData(
      id: 9,
      title: 'Nivel 5',
      biome: 'Manglar',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_mangrove.png',
    ),

    // Arrecife
    LevelData(
      id: 10,
      title: 'Nivel 1',
      biome: 'Arrecife',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_reef.png',
    ),
    LevelData(
      id: 11,
      title: 'Nivel 2',
      biome: 'Arrecife',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_reef.png',
    ),
    LevelData(
      id: 12,
      title: 'Nivel 3',
      biome: 'Arrecife',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_reef.png',
    ),
    LevelData(
      id: 13,
      title: 'Nivel 4',
      biome: 'Arrecife',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_reef.png',
    ),
    LevelData(
      id: 14,
      title: 'Nivel 5',
      biome: 'Arrecife',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_reef.png',
    ),

    // Bosque
    LevelData(
      id: 15,
      title: 'Nivel 1',
      biome: 'Bosque',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_forest.png',
    ),
    LevelData(
      id: 16,
      title: 'Nivel 2',
      biome: 'Bosque',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_forest.png',
    ),
    LevelData(
      id: 17,
      title: 'Nivel 3',
      biome: 'Bosque',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_forest.png',
    ),
    LevelData(
      id: 18,
      title: 'Nivel 4',
      biome: 'Bosque',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_forest.png',
    ),
    LevelData(
      id: 19,
      title: 'Nivel 5',
      biome: 'Bosque',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_forest.png',
    ),

    // Selva
    LevelData(
      id: 20,
      title: 'Nivel 1',
      biome: 'Selva',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_jungle.png',
    ),
    LevelData(
      id: 21,
      title: 'Nivel 2',
      biome: 'Selva',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_jungle.png',
    ),
    LevelData(
      id: 22,
      title: 'Nivel 3',
      biome: 'Selva',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_jungle.png',
    ),
    LevelData(
      id: 23,
      title: 'Nivel 4',
      biome: 'Selva',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_jungle.png',
    ),
    LevelData(
      id: 24,
      title: 'Nivel 5',
      biome: 'Selva',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_jungle.png',
    ),

    // Desierto
    LevelData(
      id: 25,
      title: 'Nivel 1',
      biome: 'Desierto',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_desert.png',
    ),
    LevelData(
      id: 26,
      title: 'Nivel 2',
      biome: 'Desierto',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_desert.png',
    ),
    LevelData(
      id: 27,
      title: 'Nivel 3',
      biome: 'Desierto',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_desert.png',
    ),
    LevelData(
      id: 28,
      title: 'Nivel 4',
      biome: 'Desierto',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_desert.png',
    ),
    LevelData(
      id: 29,
      title: 'Nivel 5',
      biome: 'Desierto',
      isUnlocked: false,
      backgroundImagePath: 'assets/images/biome_desert.png',
    ),
  ];
  List<LevelData> get levels => _levels;

  void renameLevel(int id, String newName) {
    final index = _levels.indexWhere((l) => l.id == id);
    if (index != -1) {
      final l = _levels[index];
      _levels[index] = LevelData(
        id: l.id,
        title: newName,
        biome: l.biome,
        isUnlocked: l.isUnlocked,
        backgroundImagePath: l.backgroundImagePath,
      );
      notifyListeners();
    }
  }

  Map<String, int> _levelStars = {};
  Map<String, int> get levelStars => _levelStars;

  int _totalStars = 0;
  int get totalStars => _totalStars;

  List<RewardData> _rewards = [];
  List<RewardData> get rewards => _rewards;

  List<String> _purchasedRewards = [];
  List<String> get purchasedRewards => _purchasedRewards;

  String? _studentId;

  String _playerName = 'Explorador';
  String get playerName => _playerName;

  String _playerGroup = 'Sin Grupo';
  String get playerGroup => _playerGroup;

  final List<StudentData> _students = [];
  List<StudentData> get students => _students;

  String get currentRank {
    if (_xp < 500) return 'Explorador Novato';
    if (_xp < 1500) return 'Aventurero';
    if (_xp < 3000) return 'Héroe Ecológico';
    return 'Guardián de la Naturaleza';
  }

  /// Devuelve la imagen por defecto para un bioma según su nombre.
  static String _defaultBiomeImage(String biome) {
    final lower = biome.toLowerCase();
    if (lower.contains('ciudad')) return 'assets/images/biome_city.png';
    if (lower.contains('manglar')) return 'assets/images/biome_mangrove.png';
    if (lower.contains('arrecife') || lower.contains('mar'))
      return 'assets/images/biome_reef.png';
    if (lower.contains('bosque')) return 'assets/images/biome_forest.png';
    if (lower.contains('selva') || lower.contains('jungla'))
      return 'assets/images/biome_jungle.png';
    if (lower.contains('desierto')) return 'assets/images/biome_desert.png';
    if (lower.contains('tundra')) return 'assets/images/biome_tundra.png';
    return 'assets/images/biome_forest.png';
  }

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Cargar niveles locales (incluye expediciones y preguntas custom)
    final String? levelsJson = _prefs?.getString('unlocked_levels');
    if (levelsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(levelsJson);
        final loadedLevels = decoded.map((e) => LevelData.fromJson(e)).toList();
        if (loadedLevels.length >= 30) {
          _levels = loadedLevels;
        } else {
          // Caché antiguo (menos de 30 niveles), sobrescribir con los nuevos 30
          _saveLevels();
        }
      } catch (e) {
        debugPrint('Error decoding levels from prefs: $e');
      }
    } else {
      _saveLevels(); // Guardar los 30 niveles iniciales
    }

    // Cargar corazones locales
    final localHearts = _prefs?.getInt('local_hearts');
    if (localHearts != null) {
      _hearts = localHearts;
    }

    // Cargar tiempo de recarga de corazones
    final String? regenTimeStr = _prefs?.getString('next_heart_regen_time');
    if (regenTimeStr != null) {
      _nextHeartRegenTime = DateTime.tryParse(regenTimeStr);
      _checkHeartRegenOffline();
    } else if (_hearts < 5) {
      _startHeartRegenTimer();
    }

    // Asegurar que si un nivel ya fue completado antes, el siguiente esté desbloqueado
    bool levelsModified = false;
    for (int i = 0; i < _levels.length - 1; i++) {
      final currentLevel = _levels[i];
      final stars = _levelStars[currentLevel.id.toString()] ?? 0;
      if (stars > 0 && !_levels[i + 1].isUnlocked) {
        _levels[i + 1] = _levels[i + 1].copyWith(isUnlocked: true);
        levelsModified = true;
      }
    }
    if (levelsModified) {
      _saveLevels();
    }

    notifyListeners();
  }

  Future<void> _saveLevels() async {
    if (_prefs != null) {
      final jsonList = _levels.map((l) => l.toJson()).toList();
      await _prefs!.setString('unlocked_levels', jsonEncode(jsonList));
    }
    notifyListeners();
  }

  Future<void> _saveRewards() async {
    notifyListeners();
  }

  Future<void> _saveStudents() async {
    notifyListeners();
  }

  Future<void> _saveXP() async {
    notifyListeners();
  }

  void addXP(int points) {
    _xp += points;
    _saveXP();
  }

  // ---- Métodos de Expediciones ----
  /// Crea una expedición completa con paradas.
  void addExpedition(
    String title,
    String? backgroundImagePath,
    List<ExpeditionStop> stops, {
    String biome = 'Personalizado',
  }) {
    final newId = _levels.isEmpty
        ? 0
        : _levels.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    final level = LevelData(
      id: newId,
      title: title,
      biome: biome,
      isUnlocked: true,
      backgroundImagePath: backgroundImagePath,
      stops: stops,
    );
    _levels.add(level);
    _saveLevels();

    // Persistir en Supabase de forma nativa enviando la expedición completa
    _persistLevelToSupabase(level);
  }

  /// Agrega una parada a una expedición existente.
  void addStopToExpedition(int levelId, ExpeditionStop stop) {
    final index = _levels.indexWhere((l) => l.id == levelId);
    if (index != -1) {
      final level = _levels[index];
      final updatedStops = List<ExpeditionStop>.from(level.stops)..add(stop);
      _levels[index] = level.copyWith(stops: updatedStops);
      _saveLevels();
    }
  }

  /// Marca una parada como completada y desbloquea la siguiente si corresponde.
  void markStopCompleted(int levelId, int stopId) {
    final index = _levels.indexWhere((l) => l.id == levelId);
    if (index != -1) {
      final level = _levels[index];
      if (!level.completedStops.contains(stopId)) {
        final updatedCompleted = List<int>.from(level.completedStops)
          ..add(stopId);
        _levels[index] = level.copyWith(completedStops: updatedCompleted);
        _saveLevels();
      }
    }
  }

  // ---- Métodos de Niveles ----
  void setLevelUnlocked(int id, bool isUnlocked) {
    final index = _levels.indexWhere((l) => l.id == id);
    if (index != -1) {
      _levels[index] = _levels[index].copyWith(isUnlocked: isUnlocked);
      _saveLevels();
    }
  }

  void addLevel(String title, {String biome = 'Bosque'}) {
    final newList = List<LevelData>.from(_levels);
    final newId = newList.isEmpty
        ? 0
        : newList.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    newList.add(
      LevelData(id: newId, title: title, biome: biome, isUnlocked: true),
    );
    _levels = newList;
    _saveLevels();

    // Persistir en Supabase (fire-and-forget, actualiza ID local luego)
    _persistLevelToSupabase(newList.last);
  }

  Future<void> _persistLevelToSupabase(LevelData level) async {
    try {
      final client = Supabase.instance.client;
      final existing = await client
          .from('levels')
          .select('id')
          .order('order_index', ascending: false)
          .limit(1)
          .maybeSingle();
      final nextOrder = existing != null ? (existing['id'] as int) + 1 : 0;

      // Polyfill: Empacar toda la expedición (incluyendo paradas y preguntas) como JSON en el campo biome
      final String biomePayload = jsonEncode(level.toJson());

      final result = await client
          .from('levels')
          .insert({
            'title': level.title,
            'biome': biomePayload,
            'order_index': nextOrder,
            'is_active': true,
          })
          .select()
          .single();

      // Actualizar el ID local con el ID real de Supabase
      final supabaseId = result['id'] as int;
      final newList = List<LevelData>.from(_levels);
      final idx = newList.indexWhere((l) => l.id == level.id);
      if (idx >= 0) {
        newList[idx] = newList[idx].copyWith(id: supabaseId);
        _levels = newList;
        _saveLevels();
      }
    } catch (e) {
      debugPrint('Error persisting level to Supabase: $e');
    }
  }

  void addLevelWithQuestions(
    String title,
    String? backgroundPath,
    List<QuizQuestion> questions, {
    String biome = 'Bosque',
  }) {
    final newId = _levels.isEmpty
        ? 0
        : _levels.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    final level = LevelData(
      id: newId,
      title: title,
      biome: biome,
      isUnlocked: true,
      questions: questions,
      backgroundPath: backgroundPath,
    );
    _levels.add(level);
    _saveLevels();

    // Persistir en Supabase (fire-and-forget, actualiza ID local luego)
    _persistLevelToSupabase(level);
  }

  void addQuestionsToLevel(int levelId, List<QuizQuestion> newQuestions) {
    final index = _levels.indexWhere((l) => l.id == levelId);
    if (index != -1) {
      final level = _levels[index];
      _levels[index] = level.copyWith(questions: newQuestions);
      _saveLevels();
      notifyListeners();

      // Persistir a Supabase
      _persistQuestionsToSupabase(levelId, newQuestions);
    }
  }

  Future<void> _persistQuestionsToSupabase(
    int levelId,
    List<QuizQuestion> questions,
  ) async {
    try {
      final client = Supabase.instance.client;
      // Primero, eliminar preguntas anteriores de este nivel
      await client.from('questions').delete().eq('level_id', levelId);

      // Si no hay nuevas, terminamos
      if (questions.isEmpty) return;

      // Insertar las nuevas
      final rows = questions
          .map(
            (q) => {
              'level_id': levelId,
              'question_text': q.questionText,
              'image_url': q.imageAssetPath,
              'options': q.options,
              'correct_index': q.correctOptionIndex,
              'hint': q.hint,
              'fun_fact': q.funFact,
            },
          )
          .toList();

      await client.from('questions').insert(rows);
    } catch (e) {
      debugPrint('Error saving questions to Supabase: $e');
    }
  }

  void deleteBiome(String biome) {
    final toDelete = _levels.where((l) => l.biome == biome).toList();
    final newList = List<LevelData>.from(_levels);
    newList.removeWhere((l) => l.biome == biome);
    _levels = newList;
    _saveLevels();

    // Eliminar de Supabase
    _deleteLevelsFromSupabase(toDelete.map((l) => l.id).toList());
  }

  void deleteLevel(int levelId) {
    _levels.removeWhere((l) => l.id == levelId);
    _saveLevels();

    // Eliminar de Supabase
    _deleteLevelsFromSupabase([levelId]);
  }

  Future<void> _deleteLevelsFromSupabase(List<int> ids) async {
    try {
      final client = Supabase.instance.client;
      for (final id in ids) {
        await client.from('levels').delete().eq('id', id);
      }
    } catch (e) {
      debugPrint('Error deleting levels from Supabase: $e');
    }
  }

  // ---- Métodos de Recompensas ----
  void addReward(RewardData reward) {
    _rewards.add(reward);
    _saveRewards();
  }

  void removeReward(String id) {
    _rewards.removeWhere((r) => r.id == id);
    _saveRewards();
  }

  // ---- Métodos de Estrellas ----
  void saveStarsForLevel(int levelId, int starsEarned) {
    final currentStars = _levelStars[levelId.toString()] ?? 0;
    if (starsEarned > currentStars) {
      _levelStars[levelId.toString()] = starsEarned;
      _recalculateTotalStars();
    }

    // Desbloquear el siguiente nivel automáticamente
    if (starsEarned > 0) {
      _unlockNextLevel(levelId);
    }

    // Sincronizar siempre con Supabase (fire-and-forget) para registrar actividad
    _syncStarsToSupabase(levelId, starsEarned);
  }

  void _unlockNextLevel(int currentLevelId) {
    final index = _levels.indexWhere((l) => l.id == currentLevelId);
    if (index != -1 && index + 1 < _levels.length) {
      final nextLevel = _levels[index + 1];
      if (!nextLevel.isUnlocked) {
        _levels[index + 1] = nextLevel.copyWith(isUnlocked: true);
        _saveLevels();
      }
    }
  }

  Future<void> _syncStarsToSupabase(int levelId, int starsEarned) async {
    if (_studentId == null) return;
    try {
      final client = Supabase.instance.client;

      // 1. Obtener las estrellas anteriores del alumno para este nivel
      final previousResult = await client
          .from('student_progress')
          .select('stars_earned')
          .eq('student_id', _studentId!)
          .eq('level_id', levelId)
          .maybeSingle();

      int previousStars = 0;
      if (previousResult != null) {
        previousStars = previousResult['stars_earned'] as int;
      }

      // 2. Calcular cuántas estrellas nuevas ganó
      int starsAdded = starsEarned - previousStars;

      // 3. Upsert
      await client.from('student_progress').upsert({
        'student_id': _studentId!,
        'level_id': levelId,
        'stars_earned': starsEarned > previousStars
            ? starsEarned
            : previousStars,
        'is_completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'student_id,level_id');

      // 4. Registrar en bitácora si ganó nuevas estrellas
      if (starsAdded > 0) {
        await client.from('activity_log').insert({
          'student_id': _studentId!,
          'level_id': levelId,
          'stars_added': starsAdded,
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error sincronizando estrellas a Supabase: $e');
    }
  }

  void _recalculateTotalStars() {
    int total = 0;
    for (var stars in _levelStars.values) {
      total += stars;
    }

    int spent = 0;
    for (final reward in _rewards) {
      if (_purchasedRewards.contains(reward.id)) {
        spent += reward.cost;
      }
    }
    _totalStars = total - spent;
    notifyListeners();
  }

  // ---- Métodos Viejos (Mantenidos) ----
  void unlockCard(int id) {
    if (!_unlockedCards.contains(id)) {
      _unlockedCards.add(id);
      notifyListeners();
    }
  }

  void deductHeart() {
    if (_hearts > 0) {
      _hearts -= 1;
      if (_hearts == 4) {
        _startHeartRegenTimer();
      }
      _syncHeartsToSupabase();
      notifyListeners();
    }
  }

  void restoreHearts() {
    _hearts = 5;
    _heartRegenTimer?.cancel();
    _nextHeartRegenTime = null;
    _prefs?.remove('next_heart_regen_time');
    _syncHeartsToSupabase();
    notifyListeners();
  }

  // ---- Lista de 30 Tarjetas (5 por bioma: mitad animales, mitad plantas/elementos) ----
  static const List<EncyclopediaCardData> allCards = [
    // Ciudad
    EncyclopediaCardData(
      id: 0,
      title: 'Perro Callejero',
      subtitle: 'Canis familiaris',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#001',
      typeIcon: Icons.pets,
      themeColor: Color(0xFFE67E22),
      isAnimal: true,
      biome: 'Ciudad',
    ),
    EncyclopediaCardData(
      id: 1,
      title: 'Paloma',
      subtitle: 'Columba livia',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#002',
      typeIcon: Icons.flutter_dash,
      themeColor: Color(0xFF7F8C8D),
      isAnimal: true,
      biome: 'Ciudad',
    ),
    EncyclopediaCardData(
      id: 2,
      title: 'Jacaranda',
      subtitle: 'Jacaranda mimosifolia',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#003',
      typeIcon: Icons.local_florist,
      themeColor: Color(0xFF9B59B6),
      isAnimal: false,
      biome: 'Ciudad',
    ),
    EncyclopediaCardData(
      id: 3,
      title: 'Enredadera',
      subtitle: 'Hedera helix',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#004',
      typeIcon: Icons.eco,
      themeColor: Color(0xFF27AE60),
      isAnimal: false,
      biome: 'Ciudad',
    ),
    EncyclopediaCardData(
      id: 4,
      title: 'Gato Feral',
      subtitle: 'Felis catus',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#005',
      typeIcon: Icons.pets,
      themeColor: Color(0xFF34495E),
      isAnimal: true,
      biome: 'Ciudad',
    ),

    // Manglar
    EncyclopediaCardData(
      id: 5,
      title: 'Cocodrilo',
      subtitle: 'Crocodylus acutus',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#006',
      typeIcon: Icons.pets,
      themeColor: Color(0xFF145A32),
      isAnimal: true,
      biome: 'Manglar',
    ),
    EncyclopediaCardData(
      id: 6,
      title: 'Mangle Rojo',
      subtitle: 'Rhizophora mangle',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#007',
      typeIcon: Icons.park,
      themeColor: Color(0xFFE74C3C),
      isAnimal: false,
      biome: 'Manglar',
    ),
    EncyclopediaCardData(
      id: 7,
      title: 'Garza',
      subtitle: 'Ardea alba',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#008',
      typeIcon: Icons.flutter_dash,
      themeColor: Color(0xFFBDC3C7),
      isAnimal: true,
      biome: 'Manglar',
    ),
    EncyclopediaCardData(
      id: 8,
      title: 'Cangrejo',
      subtitle: 'Brachyura',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#009',
      typeIcon: Icons.bug_report,
      themeColor: Color(0xFFC0392B),
      isAnimal: true,
      biome: 'Manglar',
    ),
    EncyclopediaCardData(
      id: 9,
      title: 'Mangle Blanco',
      subtitle: 'Laguncularia racemosa',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#010',
      typeIcon: Icons.park,
      themeColor: Color(0xFFF1C40F),
      isAnimal: false,
      biome: 'Manglar',
    ),

    // Arrecife
    EncyclopediaCardData(
      id: 10,
      title: 'Tortuga Marina',
      subtitle: 'Chelonioidea',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#011',
      typeIcon: Icons.water,
      themeColor: Color(0xFF2980B9),
      isAnimal: true,
      biome: 'Arrecife',
    ),
    EncyclopediaCardData(
      id: 11,
      title: 'Pez Payaso',
      subtitle: 'Amphiprioninae',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#012',
      typeIcon: Icons.pets,
      themeColor: Color(0xFFE67E22),
      isAnimal: true,
      biome: 'Arrecife',
    ),
    EncyclopediaCardData(
      id: 12,
      title: 'Coral Cerebro',
      subtitle: 'Faviidae',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#013',
      typeIcon: Icons.blur_on,
      themeColor: Color(0xFF8E44AD),
      isAnimal: true,
      biome: 'Arrecife',
    ),
    EncyclopediaCardData(
      id: 13,
      title: 'Alga Marina',
      subtitle: 'Chlorophyta',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#014',
      typeIcon: Icons.eco,
      themeColor: Color(0xFF229954),
      isAnimal: false,
      biome: 'Arrecife',
    ),
    EncyclopediaCardData(
      id: 14,
      title: 'Esponja de Mar',
      subtitle: 'Porifera',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#015',
      typeIcon: Icons.bubble_chart,
      themeColor: Color(0xFFF1C40F),
      isAnimal: true,
      biome: 'Arrecife',
    ),

    // Bosque
    EncyclopediaCardData(
      id: 15,
      title: 'Lobo',
      subtitle: 'Canis lupus',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#016',
      typeIcon: Icons.pets,
      themeColor: Color(0xFF7F8C8D),
      isAnimal: true,
      biome: 'Bosque',
    ),
    EncyclopediaCardData(
      id: 16,
      title: 'Búho',
      subtitle: 'Strigiformes',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#017',
      typeIcon: Icons.flutter_dash,
      themeColor: Color(0xFF5D6D7E),
      isAnimal: true,
      biome: 'Bosque',
    ),
    EncyclopediaCardData(
      id: 17,
      title: 'Ciervo',
      subtitle: 'Cervidae',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#018',
      typeIcon: Icons.pets,
      themeColor: Color(0xFFD35400),
      isAnimal: true,
      biome: 'Bosque',
    ),
    EncyclopediaCardData(
      id: 18,
      title: 'Encino',
      subtitle: 'Quercus',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#019',
      typeIcon: Icons.park,
      themeColor: Color(0xFF27AE60),
      isAnimal: false,
      biome: 'Bosque',
    ),
    EncyclopediaCardData(
      id: 19,
      title: 'Musgo',
      subtitle: 'Bryophyta',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#020',
      typeIcon: Icons.eco,
      themeColor: Color(0xFF1E8449),
      isAnimal: false,
      biome: 'Bosque',
    ),

    // Selva
    EncyclopediaCardData(
      id: 20,
      title: 'Jaguar',
      subtitle: 'Panthera onca',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#021',
      typeIcon: Icons.pets,
      themeColor: Color(0xFFF39C12),
      isAnimal: true,
      biome: 'Selva',
    ),
    EncyclopediaCardData(
      id: 21,
      title: 'Tucán',
      subtitle: 'Ramphastidae',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#022',
      typeIcon: Icons.flutter_dash,
      themeColor: Color(0xFF2ECC71),
      isAnimal: true,
      biome: 'Selva',
    ),
    EncyclopediaCardData(
      id: 22,
      title: 'Mono Araña',
      subtitle: 'Ateles',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#023',
      typeIcon: Icons.pets,
      themeColor: Color(0xFF873600),
      isAnimal: true,
      biome: 'Selva',
    ),
    EncyclopediaCardData(
      id: 23,
      title: 'Orquídea',
      subtitle: 'Orchidaceae',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#024',
      typeIcon: Icons.local_florist,
      themeColor: Color(0xFFE74C3C),
      isAnimal: false,
      biome: 'Selva',
    ),
    EncyclopediaCardData(
      id: 24,
      title: 'Liana',
      subtitle: 'Bignoniaceae',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#025',
      typeIcon: Icons.eco,
      themeColor: Color(0xFF145A32),
      isAnimal: false,
      biome: 'Selva',
    ),

    // Desierto
    EncyclopediaCardData(
      id: 25,
      title: 'Zorro del Desierto',
      subtitle: 'Vulpes zerda',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#026',
      typeIcon: Icons.pets,
      themeColor: Color(0xFFE67E22),
      isAnimal: true,
      biome: 'Desierto',
    ),
    EncyclopediaCardData(
      id: 26,
      title: 'Serpiente Cascabel',
      subtitle: 'Crotalus',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#027',
      typeIcon: Icons.gesture,
      themeColor: Color(0xFFD35400),
      isAnimal: true,
      biome: 'Desierto',
    ),
    EncyclopediaCardData(
      id: 27,
      title: 'Correcaminos',
      subtitle: 'Geococcyx',
      imagePath: 'assets/images/generic_animal_card.png',
      number: '#028',
      typeIcon: Icons.flutter_dash,
      themeColor: Color(0xFF3498DB),
      isAnimal: true,
      biome: 'Desierto',
    ),
    EncyclopediaCardData(
      id: 28,
      title: 'Cactus Saguaro',
      subtitle: 'Carnegiea gigantea',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#029',
      typeIcon: Icons.park,
      themeColor: Color(0xFF27AE60),
      isAnimal: false,
      biome: 'Desierto',
    ),
    EncyclopediaCardData(
      id: 29,
      title: 'Aloe Vera',
      subtitle: 'Aloe barbadensis',
      imagePath: 'assets/images/generic_plant_card.png',
      number: '#030',
      typeIcon: Icons.eco,
      themeColor: Color(0xFF2ECC71),
      isAnimal: false,
      biome: 'Desierto',
    ),
  ];

  // ── Nombre del jugador ─────────────────────────────────────────
  void setPlayerName(String name) {
    _playerName = name.trim().isEmpty ? 'Explorador' : name.trim();
    notifyListeners();
  }

  void setPlayerGroup(String group) {
    _playerGroup = group.trim().isEmpty ? 'Sin Grupo' : group.trim();
    notifyListeners();
  }

  // ── Comprar premio con estrellas ────────────────────────────────
  Future<bool> spendStars(String rewardId, int cost) async {
    if (_totalStars >= cost && !_purchasedRewards.contains(rewardId)) {
      _totalStars -= cost;

      _purchasedRewards.add(rewardId);
      _recalculateTotalStars();

      // Sincronizar compra a Supabase (fire-and-forget)
      _syncPurchaseToSupabase(rewardId);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Escribe la compra en la tabla purchased_rewards de Supabase.
  Future<void> _syncPurchaseToSupabase(String rewardId) async {
    if (_studentId == null) return;
    try {
      final client = Supabase.instance.client;
      await client.from('purchased_rewards').upsert({
        'student_id': _studentId!,
        'reward_id': rewardId,
      }, onConflict: 'student_id,reward_id');
    } catch (e) {
      debugPrint('⚠️ Error sincronizando compra a Supabase: $e');
    }
  }

  bool isRewardPurchased(String rewardId) {
    return _purchasedRewards.contains(rewardId);
  }

  // ── Tarjetas Coleccionables (Journal) ───────────────────────────
  EncyclopediaCardData? unlockRandomCardForBiome(String biome) {
    // 1. Filtrar las tarjetas que pertenecen a este bioma
    final biomeCards = allCards
        .where((c) => c.biome.toLowerCase() == biome.toLowerCase())
        .toList();

    // 2. Encontrar cuáles aún no están desbloqueadas
    final lockedCards = biomeCards
        .where((c) => !_unlockedCards.contains(c.id))
        .toList();

    if (lockedCards.isEmpty) {
      return null; // Ya tiene todas las tarjetas de este bioma
    }

    // 3. Seleccionar una al azar
    final random = Random();
    final selectedCard = lockedCards[random.nextInt(lockedCards.length)];

    // 4. Desbloquearla y guardar
    _unlockedCards.add(selectedCard.id);
    _syncUnlockedCardToSupabase(selectedCard.id);
    notifyListeners();

    return selectedCard;
  }

  Future<void> _syncUnlockedCardToSupabase(int cardId) async {
    if (_studentId == null) return;
    try {
      final client = Supabase.instance.client;
      await client.from('unlocked_cards').upsert({
        'student_id': _studentId!,
        'card_id': cardId,
      }, onConflict: 'student_id,card_id');
    } catch (e) {
      debugPrint('⚠️ Error sincronizando tarjeta desbloqueada a Supabase: $e');
    }
  }

  // ── Creación masiva de alumnos ─────────────────────────────────
  List<StudentData> addStudentsInBulk(
    List<String> studentNames,
    String groupId,
  ) {
    final rng = Random();
    final newStudents = <StudentData>[];

    for (final name in studentNames) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(RegExp(r'\s+'));
      final firstName = parts.first.toLowerCase();
      final lastName = parts.length > 1 ? parts.last.toLowerCase() : '';
      final groupSuffix = groupId
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
          .toLowerCase();
      final username = '${firstName[0]}$lastName$groupSuffix';

      final password = 'eco${rng.nextInt(9000) + 1000}';

      newStudents.add(
        StudentData(
          name: trimmed,
          username: username,
          password: password,
          groupId: groupId,
        ),
      );
    }

    _students.addAll(newStudents);
    _saveStudents();
    return newStudents;
  }

  List<StudentData> getStudentsForGroup(String groupId) {
    return _students.where((s) => s.groupId == groupId).toList();
  }

  void removeStudent(String username) {
    _students.removeWhere((s) => s.username == username);
    _saveStudents();
  }

  // ── Reiniciar todo el progreso ─────────────────────────────────
  Future<void> resetAllProgress() async {
    _unlockedCards = [];
    _levelStars = {};
    _totalStars = 0;
    _purchasedRewards = [];
    _xp = 0;
    restoreHearts();
    _playerName = 'Explorador';
    _playerGroup = 'Sin Grupo';
    _purchasedRewards.clear();

    _levels = [];
    await _saveLevels();
    notifyListeners();
  }

  // ── Sincronización con Supabase ─────────────────────────────────
  /// Carga datos reales del alumno desde la nube.
  /// Se llama después del login para que todas las pantallas
  /// (que leen de GameState) muestren datos correctos.
  Future<void> syncFromSupabase(String studentId) async {
    _studentId = studentId;
    final client = Supabase.instance.client;

    // Guardar referencia a las expediciones locales (con stops, preguntas, etc.)
    // para preservar datos del maestro que no están en Supabase.
    final localLevelsMap = <int, LevelData>{};
    for (final l in _levels) {
      localLevelsMap[l.id] = l;
    }

    try {
      // 1. Cargar niveles desde Supabase
      final levelsResult = await client
          .from('levels')
          .select()
          .eq('is_active', true)
          .order('order_index');

      // Obtener progreso para saber cuáles desbloquear
      final progressResult = await client
          .from('student_progress')
          .select('level_id, stars_earned')
          .eq('student_id', studentId);

      final progressMap = <String, int>{};
      for (final row in progressResult) {
        progressMap[row['level_id'].toString()] = row['stars_earned'] as int;
      }

      // Obtener tarjetas desbloqueadas
      final cardsResult = await client
          .from('unlocked_cards')
          .select('card_id')
          .eq('student_id', studentId);

      _unlockedCards.clear();
      for (final row in cardsResult) {
        _unlockedCards.add(row['card_id'] as int);
      }

      // ── Mapeo de Preguntas desde Supabase ───────────────────────────
      final questionsResult = await client.from('questions').select();
      final questionsByLevel = <int, List<QuizQuestion>>{};

      for (final row in questionsResult) {
        final levelId = row['level_id'] as int;

        // Supabase guarda options como JSONB, convertimos a List<String>
        final optionsRaw = row['options'];
        final List<String> options = optionsRaw is List
            ? optionsRaw.map((e) => e.toString()).toList()
            : <String>[];

        final q = QuizQuestion(
          questionText: row['question_text'] ?? '',
          imageAssetPath: row['image_url'] ?? '',
          options: options,
          correctOptionIndex: row['correct_index'] ?? 0,
          hint: row['hint'] ?? '',
          funFact: row['fun_fact'] ?? '',
        );

        questionsByLevel.putIfAbsent(levelId, () => []);
        questionsByLevel[levelId]!.add(q);
      }

      if (levelsResult.isNotEmpty) {
        final syncedLevels = <LevelData>[];
        int unlockedCount = 0;

        for (final json in levelsResult) {
          final id = json['id'] as int;

          // Desbloquear si es el primero (unlockedCount == 0) o si completó el anterior
          final isUnlocked =
              unlockedCount == 0 ||
              (progressMap.containsKey((id - 1).toString()) &&
                  (progressMap[(id - 1).toString()] ?? 0) > 0);

          if (isUnlocked) unlockedCount++;

          final rawBiome = json['biome'] as String?;
          final title = json['title'] as String? ?? 'Nivel $id';
          final biome = rawBiome ?? title;

          // No necesitamos consultar expedition_stops porque usamos los niveles planos (0-29)
          final stops = <ExpeditionStop>[];

          // stop_id no existe en la base de datos (niveles planos 0-29), por lo que siempre está vacío
          final completedStops = <int>[];

          final local = localLevelsMap[id];

          // Priorizamos las preguntas exactas del nodo, si no, las del bioma (id ~/ 5), si no, usamos las locales/genéricas
          final biomeIndex = id ~/ 5;
          final finalQuestions =
              questionsByLevel[id] ??
              questionsByLevel[biomeIndex] ??
              local?.questions ??
              [];

          syncedLevels.add(
            LevelData(
              id: id,
              title: title,
              biome: biome,
              isUnlocked: isUnlocked,
              questions: finalQuestions,
              backgroundPath: local?.backgroundPath,
              backgroundImagePath:
                  local?.backgroundImagePath ?? _defaultBiomeImage(biome),
              stops: stops,
              completedStops: completedStops,
            ),
          );
        }

        _levels = syncedLevels;
        _saveLevels();
        _levelStars = progressMap;
      } else {
        // Usar los niveles locales por defecto si la BD está vacía
        _levelStars = progressMap;

        // La base de datos está vacía en 'levels', así que subimos nuestros niveles locales
        try {
          final levelsToInsert = _levels
              .map(
                (l) => {
                  'id': l.id,
                  'title': l.title,
                  'biome': l.biome,
                  'order_index': l.id,
                  'is_active': true,
                },
              )
              .toList();

          await client.from('levels').upsert(levelsToInsert);
        } catch (e) {
          debugPrint('Error uploading default levels to Supabase: $e');
        }

        // Recalcular desbloqueos locales según progressMap y mapear preguntas de Supabase
        bool levelsModified = false;
        for (int i = 0; i < _levels.length; i++) {
          final currentLevel = _levels[i];
          final stars = _levelStars[currentLevel.id.toString()] ?? 0;

          bool shouldUpdate = false;
          bool newUnlocked = currentLevel.isUnlocked;
          List<QuizQuestion> newQuestions = currentLevel.questions;

          if (i < _levels.length - 1 &&
              stars > 0 &&
              !_levels[i + 1].isUnlocked) {
            _levels[i + 1] = _levels[i + 1].copyWith(isUnlocked: true);
            levelsModified = true;
          }

          // Asignar preguntas de Supabase si existen (exacta o de su bioma)
          final biomeIndex = currentLevel.id ~/ 5;
          if (questionsByLevel.containsKey(currentLevel.id)) {
            newQuestions = questionsByLevel[currentLevel.id]!;
            shouldUpdate = true;
          } else if (questionsByLevel.containsKey(biomeIndex)) {
            newQuestions = questionsByLevel[biomeIndex]!;
            shouldUpdate = true;
          }

          if (shouldUpdate) {
            _levels[i] = currentLevel.copyWith(questions: newQuestions);
            levelsModified = true;
          }
        }
        if (levelsModified) _saveLevels();
      }

      // 2. Cargar recompensas del grupo del alumno
      final membership = await client
          .from('group_members')
          .select('group_id')
          .eq('student_id', studentId)
          .limit(1)
          .maybeSingle();

      if (membership != null) {
        final groupId = membership['group_id'];
        final rewardsResult = await client
            .from('rewards')
            .select()
            .eq('group_id', groupId);

        final iconMap = <String, IconData>{
          'card_giftcard': Icons.card_giftcard,
          'star': Icons.star,
          'videogame_asset': Icons.videogame_asset,
          'color_lens': Icons.color_lens,
          'face': Icons.face,
          'lightbulb': Icons.lightbulb,
          'wallpaper': Icons.wallpaper,
          'crop_square': Icons.crop_square,
        };

        final colorMap = <String, int>{
          '#8E44AD': 0xFF8E44AD,
          '#E67E22': 0xFFE67E22,
          '#27AE60': 0xFF27AE60,
          '#2B9BF4': 0xFF2B9BF4,
          '#F1C40F': 0xFFF1C40F,
        };

        if (rewardsResult.isNotEmpty) {
          final syncedRewards = rewardsResult.map((json) {
            final iconName = json['icon_name'] as String? ?? 'card_giftcard';
            final colorHex = json['color_hex'] as String? ?? '#8E44AD';
            return RewardData(
              id: json['id'].toString(),
              title: json['title'] as String? ?? '',
              subtitle: json['subtitle'] as String? ?? '',
              cost: json['cost'] as int? ?? 50,
              colorValue: colorMap[colorHex] ?? 0xFF8E44AD,
              iconCodePoint:
                  (iconMap[iconName] ?? Icons.card_giftcard).codePoint,
            );
          }).toList();
          _rewards = syncedRewards;
          _saveRewards();
        }
      }

      // 3. Cargar premios comprados
      final purchasedResult = await client
          .from('purchased_rewards')
          .select('reward_id')
          .eq('student_id', studentId);

      final purchasedIds = purchasedResult
          .map<String>((r) => r['reward_id'].toString())
          .toList();
      _purchasedRewards = purchasedIds;

      // 4. Cargar corazones
      final profileResult = await client
          .from('profiles')
          .select('hearts')
          .eq('id', studentId)
          .maybeSingle();

      if (profileResult != null) {
        _hearts = profileResult['hearts'] as int? ?? 5;
        _prefs?.setInt('local_hearts', _hearts);

        if (_hearts >= 5) {
          _heartRegenTimer?.cancel();
          _nextHeartRegenTime = null;
          _prefs?.remove('next_heart_regen_time');
        } else if (_nextHeartRegenTime == null) {
          _startHeartRegenTimer();
        }
      }

      // 5. Recalcular estrellas totales
      _recalculateTotalStars();
    } catch (e) {
      // Si falla la sync, GameState sigue funcionando con datos locales
      debugPrint('⚠️ Error sincronizando con Supabase: $e');
    }
  }
}
