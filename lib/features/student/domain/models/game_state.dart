import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../repositories/database_repository.dart';
import 'quiz_model.dart';

class EncyclopediaCardData {
  final int id;
  final String title;
  final String subtitle;
  final String imagePath;
  final String number;
  final IconData typeIcon;
  final Color themeColor;

  const EncyclopediaCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.number,
    required this.typeIcon,
    required this.themeColor,
  });
}

class LevelData {
  final int id;
  final String title;
  final bool isUnlocked;
  final List<QuizQuestion> questions;
  final String? backgroundPath;

  LevelData({
    required this.id,
    required this.title,
    this.isUnlocked = false,
    this.questions = const [],
    this.backgroundPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isUnlocked': isUnlocked,
        'questions': questions.map((q) => q.toJson()).toList(),
        'backgroundPath': backgroundPath,
      };

  factory LevelData.fromJson(Map<String, dynamic> json) => LevelData(
        id: json['id'],
        title: json['title'],
        isUnlocked: json['isUnlocked'] ?? false,
        questions: json['questions'] != null
            ? (json['questions'] as List)
                .map((q) => QuizQuestion.fromJson(q))
                .toList()
            : [],
        backgroundPath: json['backgroundPath'],
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
  final IDatabaseRepository _prefs;

  GameState(this._prefs);

  List<int> _unlockedCards = [0, 4];
  List<int> get unlockedCards => _unlockedCards;

  int _hearts = 5;
  int get hearts => _hearts;

  int _xp = 0;
  int get xp => _xp;

  List<LevelData> _levels = [];
  List<LevelData> get levels => _levels;

  List<RewardData> _rewards = [];
  List<RewardData> get rewards => _rewards;

  Map<String, int> _levelStars = {};
  Map<String, int> get levelStars => _levelStars;

  int _totalStars = 0;
  int get totalStars => _totalStars;

  String _playerName = 'Explorador';
  String get playerName => _playerName;

  List<String> _purchasedRewards = [];
  List<String> get purchasedRewards => _purchasedRewards;

  List<StudentData> _students = [];
  List<StudentData> get students => _students;

  String get currentRank {
    if (_xp < 500) return 'Explorador Novato';
    if (_xp < 1500) return 'Aventurero';
    if (_xp < 3000) return 'Héroe Ecológico';
    return 'Guardián de la Naturaleza';
  }

  Future<void> init() async {
    // 1. Cargar tarjetas
    final String? cardsJson = await _prefs.getString('unlocked_cards');
    if (cardsJson != null) {
      _unlockedCards = List<int>.from(jsonDecode(cardsJson));
    }

    // 2. Cargar niveles
    final String? levelsJson = await _prefs.getString('dynamic_levels');
    if (levelsJson != null) {
      final List<dynamic> decoded = jsonDecode(levelsJson);
      _levels = decoded.map((e) => LevelData.fromJson(e)).toList();
    } else {
      _initDefaultLevels();
    }

    // 3. Cargar recompensas
    final String? rewardsJson = await _prefs.getString('dynamic_rewards');
    if (rewardsJson != null) {
      final List<dynamic> decoded = jsonDecode(rewardsJson);
      _rewards = decoded.map((e) => RewardData.fromJson(e)).toList();
    } else {
      _initDefaultRewards();
    }

    // 4. Cargar estrellas por nivel
    final String? starsJson = await _prefs.getString('level_stars');
    if (starsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(starsJson);
      _levelStars = decoded.map((key, value) => MapEntry(key, value as int));
      _recalculateTotalStars();
    }

    // 5. Cargar vidas
    final int? savedHearts = await _prefs.getInt('hearts');
    if (savedHearts != null) {
      _hearts = savedHearts;
    }

    // 6. Cargar nombre del jugador
    final String? savedName = await _prefs.getString('player_name');
    if (savedName != null && savedName.isNotEmpty) {
      _playerName = savedName;
    }

    // 7. Cargar premios comprados
    final String? purchasedJson = await _prefs.getString('purchased_rewards');
    if (purchasedJson != null) {
      _purchasedRewards = List<String>.from(jsonDecode(purchasedJson));
    }

    // 8. Cargar alumnos registrados
    final String? studentsJson = await _prefs.getString('registered_students');
    if (studentsJson != null) {
      final List<dynamic> decoded = jsonDecode(studentsJson);
      _students = decoded.map((e) => StudentData.fromJson(e)).toList();
    }

    // 9. Cargar XP
    final int? savedXP = await _prefs.getInt('xp');
    if (savedXP != null) {
      _xp = savedXP;
    }

    notifyListeners();
  }

  void _initDefaultLevels() {
    _levels = [
      LevelData(id: 0, title: 'Ciudad', isUnlocked: true),
      LevelData(id: 1, title: 'Manglar', isUnlocked: false),
      LevelData(id: 2, title: 'Arrecife', isUnlocked: false),
      LevelData(id: 3, title: 'Bosque', isUnlocked: false),
      LevelData(id: 4, title: 'Selva', isUnlocked: false),
      LevelData(id: 5, title: 'Desierto', isUnlocked: false),
    ];
    _saveLevels();
  }

  void _initDefaultRewards() {
    _rewards = [
      RewardData(id: 'r1', title: 'Avatar Especial', subtitle: 'Ocelote', cost: 50, colorValue: 0xFF8E44AD, iconCodePoint: Icons.face.codePoint),
      RewardData(id: 'r2', title: 'Pista Extra', subtitle: 'Para el Quiz', cost: 10, colorValue: 0xFFF1C40F, iconCodePoint: Icons.lightbulb_outline.codePoint),
      RewardData(id: 'r3', title: 'Fondo Animado', subtitle: 'Desierto', cost: 100, colorValue: 0xFF27AE60, iconCodePoint: Icons.wallpaper.codePoint),
      RewardData(id: 'r4', title: 'Marco de Oro', subtitle: 'Para tu Perfil', cost: 200, colorValue: 0xFFE67E22, iconCodePoint: Icons.crop_square.codePoint),
    ];
    _saveRewards();
  }

  Future<void> _saveLevels() async {
    final jsonList = _levels.map((e) => e.toJson()).toList();
    await _prefs.saveString('dynamic_levels', jsonEncode(jsonList));
    notifyListeners();
  }

  Future<void> _saveRewards() async {
    final jsonList = _rewards.map((e) => e.toJson()).toList();
    await _prefs.saveString('dynamic_rewards', jsonEncode(jsonList));
    notifyListeners();
  }

  Future<void> _saveStudents() async {
    final jsonList = _students.map((e) => e.toJson()).toList();
    await _prefs.saveString('registered_students', jsonEncode(jsonList));
    notifyListeners();
  }

  Future<void> _saveXP() async {
    await _prefs.saveInt('xp', _xp);
    notifyListeners();
  }

  void addXP(int points) {
    _xp += points;
    _saveXP();
  }

  // ---- Métodos de Niveles ----
  void setLevelUnlocked(int id, bool isUnlocked) {
    final index = _levels.indexWhere((l) => l.id == id);
    if (index != -1) {
      final old = _levels[index];
      _levels[index] = LevelData(
        id: id,
        title: old.title,
        isUnlocked: isUnlocked,
        questions: old.questions,
        backgroundPath: old.backgroundPath,
      );
      _saveLevels();
    }
  }

  void addLevel(String title) {
    final newId = _levels.isEmpty ? 0 : _levels.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    _levels.add(LevelData(id: newId, title: title, isUnlocked: true));
    _saveLevels();
  }

  void addLevelWithQuestions(String title, String? backgroundPath, List<QuizQuestion> questions) {
    final newId = _levels.isEmpty ? 0 : _levels.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    _levels.add(LevelData(
      id: newId,
      title: title,
      isUnlocked: true,
      questions: questions,
      backgroundPath: backgroundPath,
    ));
    _saveLevels();
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
      _prefs.saveString('level_stars', jsonEncode(_levelStars));
      _recalculateTotalStars();
    }
  }

  void _recalculateTotalStars() {
    int total = 0;
    for (var stars in _levelStars.values) {
      total += stars;
    }
    _totalStars = total;
    notifyListeners();
  }

  // ---- Métodos Viejos (Mantenidos) ----
  void unlockCard(int id) {
    if (!_unlockedCards.contains(id)) {
      _unlockedCards.add(id);
      _prefs.saveString('unlocked_cards', jsonEncode(_unlockedCards));
      notifyListeners();
    }
  }

  void deductHeart() {
    if (_hearts > 0) {
      _hearts -= 1;
      _prefs.saveInt('hearts', _hearts);
      notifyListeners();
    }
  }

  void restoreHearts() {
    _hearts = 5;
    _prefs.saveInt('hearts', _hearts);
    notifyListeners();
  }

  // ---- Lista de tarjetas (Fija por ahora, ya que el profe aceptó que el journal quede igual) ----
  static const List<EncyclopediaCardData> allCards = [
    EncyclopediaCardData(
      id: 0,
      title: 'Ajolote',
      subtitle: 'Ambystoma mexicanum',
      imagePath: 'assets/images/card_ajolote_1778451548363.png',
      number: '#012',
      typeIcon: Icons.water_drop,
      themeColor: Color(0xFF873600), // Brown
    ),
    EncyclopediaCardData(
      id: 1,
      title: 'Tucán',
      subtitle: 'Ramphastidae',
      imagePath: 'assets/images/quiz_toucan_1778462119800.png',
      number: '#045',
      typeIcon: Icons.flutter_dash,
      themeColor: Color(0xFF27AE60), // Green
    ),
    EncyclopediaCardData(
      id: 2,
      title: 'Tortuga Marina',
      subtitle: 'Chelonioidea',
      imagePath: 'assets/images/quiz_turtle_1778463514370.png',
      number: '#023',
      typeIcon: Icons.water,
      themeColor: Color(0xFF2980B9), // Blue
    ),
    EncyclopediaCardData(
      id: 3,
      title: 'Mariposa Monarca',
      subtitle: 'Danaus plexippus',
      imagePath: 'assets/images/quiz_butterfly_1778463527262.png',
      number: '#008',
      typeIcon: Icons.bug_report,
      themeColor: Color(0xFFD35400), // Orange
    ),
    EncyclopediaCardData(
      id: 4,
      title: 'Jaguar',
      subtitle: 'Panthera onca',
      imagePath: 'assets/images/card_jaguar_1778451534575.png',
      number: '#001',
      typeIcon: Icons.pets,
      themeColor: Color(0xFFF39C12), // Yellow/Orange
    ),
    EncyclopediaCardData(
      id: 5,
      title: 'Zorro del Desierto',
      subtitle: 'Vulpes zerda',
      imagePath: 'assets/images/quiz_fox_1778463541718.png',
      number: '#055',
      typeIcon: Icons.pets,
      themeColor: Color(0xFFE67E22), // Sand Orange
    ),
  ];

  // ── Nombre del jugador ─────────────────────────────────────────
  void setPlayerName(String name) {
    _playerName = name.trim().isEmpty ? 'Explorador' : name.trim();
    _prefs.saveString('player_name', _playerName);
    notifyListeners();
  }

  // ── Comprar premio con estrellas ────────────────────────────────
  Future<bool> spendStars(String rewardId, int cost) async {
    if (_totalStars >= cost && !_purchasedRewards.contains(rewardId)) {
      _totalStars -= cost;
      
      final currentSpent = await _prefs.getInt('spent_stars') ?? 0;
      await _prefs.saveInt('spent_stars', currentSpent + cost);

      _purchasedRewards.add(rewardId);
      await _prefs.saveString('purchased_rewards', jsonEncode(_purchasedRewards));
      notifyListeners();
      return true;
    }
    return false;
  }

  bool isRewardPurchased(String rewardId) {
    return _purchasedRewards.contains(rewardId);
  }

  // ── Creación masiva de alumnos ─────────────────────────────────
  List<StudentData> addStudentsInBulk(List<String> studentNames, String groupId) {
    final rng = Random();
    final newStudents = <StudentData>[];

    for (final name in studentNames) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(RegExp(r'\s+'));
      final firstName = parts.first.toLowerCase();
      final lastName = parts.length > 1 ? parts.last.toLowerCase() : '';
      final groupSuffix = groupId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
      final username = '${firstName[0]}$lastName$groupSuffix';

      final password = 'eco${rng.nextInt(9000) + 1000}';

      newStudents.add(StudentData(
        name: trimmed,
        username: username,
        password: password,
        groupId: groupId,
      ));
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
    await _prefs.saveString('unlocked_cards', '[]');

    _levelStars = {};
    _totalStars = 0;
    await _prefs.saveString('level_stars', '{}');
    await _prefs.saveInt('spent_stars', 0);

    _purchasedRewards = [];
    await _prefs.saveString('purchased_rewards', '[]');
    
    _xp = 0;
    await _prefs.saveInt('xp', 0);

    restoreHearts();

    _playerName = 'Explorador';
    await _prefs.saveString('player_name', 'Explorador');

    final defaultLevels = [
      LevelData(id: 0, title: 'Ciudad', isUnlocked: true),
      LevelData(id: 1, title: 'Manglar', isUnlocked: false),
      LevelData(id: 2, title: 'Arrecife', isUnlocked: false),
      LevelData(id: 3, title: 'Bosque', isUnlocked: false),
      LevelData(id: 4, title: 'Selva', isUnlocked: false),
      LevelData(id: 5, title: 'Desierto', isUnlocked: false),
    ];
    final customLevels = _levels
        .where((l) => l.id > 5)
        .map((l) => LevelData(
              id: l.id,
              title: l.title,
              isUnlocked: false,
              questions: l.questions,
              backgroundPath: l.backgroundPath,
            ))
        .toList();
    _levels = [...defaultLevels, ...customLevels];
    await _saveLevels();
    notifyListeners();
  }
}
