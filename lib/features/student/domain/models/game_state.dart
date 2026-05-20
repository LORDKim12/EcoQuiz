import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Modelo para representar un alumno generado.
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

class GameState {
  static final GameState instance = GameState._internal();
  GameState._internal();

  final ValueNotifier<List<int>> unlockedCards = ValueNotifier<List<int>>([0, 4]);
  final ValueNotifier<int> hearts = ValueNotifier<int>(5);
  
  // Nuevos estados dinámicos
  final ValueNotifier<List<LevelData>> levels = ValueNotifier<List<LevelData>>([]);
  final ValueNotifier<List<RewardData>> rewards = ValueNotifier<List<RewardData>>([]);
  
  // Mapea el id del nivel a las estrellas obtenidas (0-3)
  final ValueNotifier<Map<String, int>> levelStars = ValueNotifier<Map<String, int>>({});
  
  // Total de estrellas sumadas
  final ValueNotifier<int> totalStars = ValueNotifier<int>(0);

  // Nombre del jugador
  final ValueNotifier<String> playerName = ValueNotifier<String>('Explorador');

  // Premios comprados (IDs)
  final ValueNotifier<List<String>> purchasedRewards = ValueNotifier<List<String>>([]);

  // Lista de alumnos registrados
  final ValueNotifier<List<StudentData>> students = ValueNotifier<List<StudentData>>([]);

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // 1. Cargar tarjetas
    final String? cardsJson = _prefs?.getString('unlocked_cards');
    if (cardsJson != null) {
      unlockedCards.value = List<int>.from(jsonDecode(cardsJson));
    }

    // 2. Cargar niveles
    final String? levelsJson = _prefs?.getString('dynamic_levels');
    if (levelsJson != null) {
      final List<dynamic> decoded = jsonDecode(levelsJson);
      levels.value = decoded.map((e) => LevelData.fromJson(e)).toList();
    } else {
      _initDefaultLevels();
    }

    // 3. Cargar recompensas
    final String? rewardsJson = _prefs?.getString('dynamic_rewards');
    if (rewardsJson != null) {
      final List<dynamic> decoded = jsonDecode(rewardsJson);
      rewards.value = decoded.map((e) => RewardData.fromJson(e)).toList();
    } else {
      _initDefaultRewards();
    }

    // 4. Cargar estrellas por nivel
    final String? starsJson = _prefs?.getString('level_stars');
    if (starsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(starsJson);
      levelStars.value = decoded.map((key, value) => MapEntry(key, value as int));
      _recalculateTotalStars();
    }

    // 5. Cargar vidas
    final int? savedHearts = _prefs?.getInt('hearts');
    if (savedHearts != null) {
      hearts.value = savedHearts;
    }

    // 6. Cargar nombre del jugador
    final String? savedName = _prefs?.getString('player_name');
    if (savedName != null && savedName.isNotEmpty) {
      playerName.value = savedName;
    }

    // 7. Cargar premios comprados
    final String? purchasedJson = _prefs?.getString('purchased_rewards');
    if (purchasedJson != null) {
      purchasedRewards.value = List<String>.from(jsonDecode(purchasedJson));
    }

    // 8. Cargar alumnos registrados
    final String? studentsJson = _prefs?.getString('registered_students');
    if (studentsJson != null) {
      final List<dynamic> decoded = jsonDecode(studentsJson);
      students.value = decoded.map((e) => StudentData.fromJson(e)).toList();
    }
  }

  void _initDefaultLevels() {
    levels.value = [
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
    rewards.value = [
      RewardData(id: 'r1', title: 'Avatar Especial', subtitle: 'Ocelote', cost: 50, colorValue: 0xFF8E44AD, iconCodePoint: Icons.face.codePoint),
      RewardData(id: 'r2', title: 'Pista Extra', subtitle: 'Para el Quiz', cost: 10, colorValue: 0xFFF1C40F, iconCodePoint: Icons.lightbulb_outline.codePoint),
      RewardData(id: 'r3', title: 'Fondo Animado', subtitle: 'Desierto', cost: 100, colorValue: 0xFF27AE60, iconCodePoint: Icons.wallpaper.codePoint),
      RewardData(id: 'r4', title: 'Marco de Oro', subtitle: 'Para tu Perfil', cost: 200, colorValue: 0xFFE67E22, iconCodePoint: Icons.crop_square.codePoint),
    ];
    _saveRewards();
  }

  void _saveLevels() {
    final jsonList = levels.value.map((e) => e.toJson()).toList();
    _prefs?.setString('dynamic_levels', jsonEncode(jsonList));
  }

  void _saveRewards() {
    final jsonList = rewards.value.map((e) => e.toJson()).toList();
    _prefs?.setString('dynamic_rewards', jsonEncode(jsonList));
  }

  void _saveStudents() {
    final jsonList = students.value.map((e) => e.toJson()).toList();
    _prefs?.setString('registered_students', jsonEncode(jsonList));
  }

  // ---- Métodos de Niveles ----
  void setLevelUnlocked(int id, bool isUnlocked) {
    final newList = List<LevelData>.from(levels.value);
    final index = newList.indexWhere((l) => l.id == id);
    if (index != -1) {
      final old = newList[index];
      newList[index] = LevelData(
        id: id,
        title: old.title,
        isUnlocked: isUnlocked,
        questions: old.questions,
        backgroundPath: old.backgroundPath,
      );
      levels.value = newList;
      _saveLevels();
    }
  }

  void addLevel(String title) {
    final newList = List<LevelData>.from(levels.value);
    final newId = newList.isEmpty ? 0 : newList.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    newList.add(LevelData(id: newId, title: title, isUnlocked: true));
    levels.value = newList;
    _saveLevels();
  }

  /// Crea un nuevo nivel con preguntas personalizadas y fondo opcional.
  void addLevelWithQuestions(String title, String? backgroundPath, List<QuizQuestion> questions) {
    final newList = List<LevelData>.from(levels.value);
    final newId = newList.isEmpty ? 0 : newList.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    newList.add(LevelData(
      id: newId,
      title: title,
      isUnlocked: true,
      questions: questions,
      backgroundPath: backgroundPath,
    ));
    levels.value = newList;
    _saveLevels();
  }

  // ---- Métodos de Recompensas ----
  void addReward(RewardData reward) {
    final newList = List<RewardData>.from(rewards.value)..add(reward);
    rewards.value = newList;
    _saveRewards();
  }

  void removeReward(String id) {
    final newList = List<RewardData>.from(rewards.value)..removeWhere((r) => r.id == id);
    rewards.value = newList;
    _saveRewards();
  }

  // ---- Métodos de Estrellas ----
  void saveStarsForLevel(int levelId, int starsEarned) {
    final currentStars = levelStars.value[levelId.toString()] ?? 0;
    // Solo guardamos si el nuevo puntaje es mayor al anterior
    if (starsEarned > currentStars) {
      final newMap = Map<String, int>.from(levelStars.value);
      newMap[levelId.toString()] = starsEarned;
      levelStars.value = newMap;
      _prefs?.setString('level_stars', jsonEncode(newMap));
      _recalculateTotalStars();
    }
  }

  void _recalculateTotalStars() {
    int total = 0;
    for (var stars in levelStars.value.values) {
      total += stars;
    }
    totalStars.value = total;
  }

  // ---- Métodos Viejos (Mantenidos) ----
  void unlockCard(int id) {
    if (!unlockedCards.value.contains(id)) {
      final newList = List.from(unlockedCards.value)..add(id);
      unlockedCards.value = List<int>.from(newList);
      _prefs?.setString('unlocked_cards', jsonEncode(newList));
    }
  }

  void deductHeart() {
    if (hearts.value > 0) {
      hearts.value -= 1;
      _prefs?.setInt('hearts', hearts.value);
    }
  }

  void restoreHearts() {
    hearts.value = 5;
    _prefs?.setInt('hearts', hearts.value);
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
    playerName.value = name.trim().isEmpty ? 'Explorador' : name.trim();
    _prefs?.setString('player_name', playerName.value);
  }

  // ── Comprar premio con estrellas ────────────────────────────────
  bool spendStars(String rewardId, int cost) {
    if (totalStars.value >= cost && !purchasedRewards.value.contains(rewardId)) {
      totalStars.value -= cost;
      // Recalcular las estrellas restando el costo
      _prefs?.setInt('spent_stars', (_prefs?.getInt('spent_stars') ?? 0) + cost);

      final newPurchased = List<String>.from(purchasedRewards.value)..add(rewardId);
      purchasedRewards.value = newPurchased;
      _prefs?.setString('purchased_rewards', jsonEncode(newPurchased));
      return true;
    }
    return false;
  }

  bool isRewardPurchased(String rewardId) {
    return purchasedRewards.value.contains(rewardId);
  }

  // ── Creación masiva de alumnos ─────────────────────────────────
  /// Recibe una lista de nombres y genera automáticamente usuario y contraseña
  /// para cada alumno, asignándolos al grupo indicado.
  List<StudentData> addStudentsInBulk(List<String> studentNames, String groupId) {
    final rng = Random();
    final newStudents = <StudentData>[];

    for (final name in studentNames) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) continue;

      // Generar username: primera letra + apellido + grupo (sin espacios)
      final parts = trimmed.split(RegExp(r'\s+'));
      final firstName = parts.first.toLowerCase();
      final lastName = parts.length > 1 ? parts.last.toLowerCase() : '';
      final groupSuffix = groupId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
      final username = '${firstName[0]}$lastName$groupSuffix';

      // Generar contraseña simple: eco + 4 dígitos aleatorios
      final password = 'eco${rng.nextInt(9000) + 1000}';

      newStudents.add(StudentData(
        name: trimmed,
        username: username,
        password: password,
        groupId: groupId,
      ));
    }

    final updatedList = List<StudentData>.from(students.value)..addAll(newStudents);
    students.value = updatedList;
    _saveStudents();
    return newStudents;
  }

  /// Obtiene los alumnos de un grupo específico.
  List<StudentData> getStudentsForGroup(String groupId) {
    return students.value.where((s) => s.groupId == groupId).toList();
  }

  /// Elimina un alumno por su username.
  void removeStudent(String username) {
    final newList = List<StudentData>.from(students.value)
      ..removeWhere((s) => s.username == username);
    students.value = newList;
    _saveStudents();
  }

  // ── Reiniciar todo el progreso ─────────────────────────────────
  /// Limpia todas las tarjetas, estrellas, niveles y restaura corazones.
  /// Útil para la demo (reiniciar entre alumnos).
  void resetAllProgress() {
    // Limpiar tarjetas desbloqueadas
    unlockedCards.value = [];
    _prefs?.setString('unlocked_cards', '[]');

    // Limpiar estrellas de niveles
    levelStars.value = {};
    totalStars.value = 0;
    _prefs?.setString('level_stars', '{}');
    _prefs?.setInt('spent_stars', 0);

    // Limpiar premios comprados
    purchasedRewards.value = [];
    _prefs?.setString('purchased_rewards', '[]');

    // Restaurar corazones
    restoreHearts();

    // Reiniciar nombre
    playerName.value = 'Explorador';
    _prefs?.setString('player_name', 'Explorador');

    // Reiniciar niveles: solo el primero desbloqueado, preservando niveles personalizados
    final defaultLevels = [
      LevelData(id: 0, title: 'Ciudad', isUnlocked: true),
      LevelData(id: 1, title: 'Manglar', isUnlocked: false),
      LevelData(id: 2, title: 'Arrecife', isUnlocked: false),
      LevelData(id: 3, title: 'Bosque', isUnlocked: false),
      LevelData(id: 4, title: 'Selva', isUnlocked: false),
      LevelData(id: 5, title: 'Desierto', isUnlocked: false),
    ];
    // Preservar niveles personalizados del profesor (id > 5)
    final customLevels = levels.value
        .where((l) => l.id > 5)
        .map((l) => LevelData(
              id: l.id,
              title: l.title,
              isUnlocked: false,
              questions: l.questions,
              backgroundPath: l.backgroundPath,
            ))
        .toList();
    levels.value = [...defaultLevels, ...customLevels];
    _saveLevels();
  }
}
