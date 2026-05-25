
import 'dart:math';
import 'package:flutter/material.dart';

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
  final String biome;
  final bool isUnlocked;
  final List<QuizQuestion> questions;
  final String? backgroundPath;

  LevelData({
    required this.id,
    required this.title,
    this.biome = '',
    this.isUnlocked = false,
    this.questions = const [],
    this.backgroundPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'biome': biome,
        'isUnlocked': isUnlocked,
        'questions': questions.map((q) => q.toJson()).toList(),
        'backgroundPath': backgroundPath,
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

  int _xp = 0;
  int get xp => _xp;

  List<LevelData> _levels = [
    LevelData(id: 0, title: 'Nivel 1', biome: 'Ciudad', isUnlocked: true),
    LevelData(id: 1, title: 'Nivel 1', biome: 'Manglar', isUnlocked: false),
    LevelData(id: 2, title: 'Nivel 1', biome: 'Arrecife', isUnlocked: false),
    LevelData(id: 3, title: 'Nivel 1', biome: 'Bosque', isUnlocked: false),
    LevelData(id: 4, title: 'Nivel 1', biome: 'Selva', isUnlocked: false),
    LevelData(id: 5, title: 'Nivel 1', biome: 'Desierto', isUnlocked: false),
  ];
  List<LevelData> get levels => _levels;

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

  Future<void> init() async {
    // La inicialización local fue removida por diseño.
    // Todos los datos se cargarán usando syncFromSupabase() 
    // después de iniciar sesión.
    notifyListeners();
  }

  Future<void> _saveLevels() async {
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

  // ---- Métodos de Niveles ----
  void setLevelUnlocked(int id, bool isUnlocked) {
    final index = _levels.indexWhere((l) => l.id == id);
    if (index != -1) {
      final old = _levels[index];
      _levels[index] = LevelData(
        id: id,
        title: old.title,
        biome: old.biome,
        isUnlocked: isUnlocked,
        questions: old.questions,
        backgroundPath: old.backgroundPath,
      );
      _saveLevels();
    }
  }

  void addLevel(String title, {String biome = 'Bosque'}) {
    final newList = List<LevelData>.from(_levels);
    final newId = newList.isEmpty ? 0 : newList.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    newList.add(LevelData(id: newId, title: title, biome: biome, isUnlocked: true));
    _levels = newList;
    _saveLevels();

    // Persistir en Supabase (fire-and-forget, actualiza ID local luego)
    _persistLevelToSupabase(title, biome, newId);
  }

  Future<void> _persistLevelToSupabase(String title, String biome, int localId) async {
    try {
      final client = Supabase.instance.client;
      final existing = await client
          .from('levels')
          .select('id')
          .order('order_index', ascending: false)
          .limit(1)
          .maybeSingle();
      final nextOrder = existing != null ? (existing['id'] as int) + 1 : 0;

      final result = await client.from('levels').insert({
        'title': title,
        'biome': biome.toLowerCase(),
        'order_index': nextOrder,
        'is_active': true,
      }).select().single();

      // Actualizar el ID local con el ID real de Supabase
      final supabaseId = result['id'] as int;
      final newList = List<LevelData>.from(_levels);
      final idx = newList.indexWhere((l) => l.id == localId && l.title == title && l.biome == biome);
      if (idx >= 0) {
        newList[idx] = LevelData(id: supabaseId, title: title, biome: biome, isUnlocked: true);
        _levels = newList;
        _saveLevels();
      }
    } catch (e) {
      debugPrint('Error persisting level to Supabase: $e');
    }
  }

  void addLevelWithQuestions(String title, String? backgroundPath, List<QuizQuestion> questions, {String biome = 'Bosque'}) {
    final newId = _levels.isEmpty ? 0 : _levels.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    _levels.add(LevelData(
      id: newId,
      title: title,
      biome: biome,
      isUnlocked: true,
      questions: questions,
      backgroundPath: backgroundPath,
    ));
    _saveLevels();

    // Persistir en Supabase (fire-and-forget, actualiza ID local luego)
    _persistLevelToSupabase(title, biome, newId);
  }

  void addQuestionsToLevel(int levelId, List<QuizQuestion> newQuestions) {
    final index = _levels.indexWhere((l) => l.id == levelId);
    if (index != -1) {
      final level = _levels[index];
      final updatedQuestions = List<QuizQuestion>.from(level.questions)..addAll(newQuestions);
      _levels[index] = LevelData(
        id: level.id,
        title: level.title,
        biome: level.biome,
        isUnlocked: level.isUnlocked,
        questions: updatedQuestions,
        backgroundPath: level.backgroundPath,
      );
      _saveLevels();
      
      // En una implementación completa con Supabase, aquí se guardarían las preguntas.
      // Por ahora, como Supabase _persistLevelToSupabase guarda el nivel principal, 
      // y la lógica de preguntas está en memoria para la demo, con _saveLevels() es suficiente
      // para persistir localmente.
      notifyListeners();
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
    
    // Sincronizar siempre con Supabase (fire-and-forget) para registrar actividad
    _syncStarsToSupabase(levelId, starsEarned);
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
        'stars_earned': starsEarned > previousStars ? starsEarned : previousStars,
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
      notifyListeners();
    }
  }

  void restoreHearts() {
    _hearts = 5;
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
    _levelStars = {};
    _totalStars = 0;
    _purchasedRewards = [];
    _xp = 0;
    restoreHearts();
    _playerName = 'Explorador';
    _playerGroup = 'Sin Grupo';
    _purchasedRewards.clear();

    final defaultLevels = [
      LevelData(id: 0, title: 'Nivel 1', biome: 'Ciudad', isUnlocked: true),
      LevelData(id: 1, title: 'Nivel 1', biome: 'Manglar', isUnlocked: false),
      LevelData(id: 2, title: 'Nivel 1', biome: 'Arrecife', isUnlocked: false),
      LevelData(id: 3, title: 'Nivel 1', biome: 'Bosque', isUnlocked: false),
      LevelData(id: 4, title: 'Nivel 1', biome: 'Selva', isUnlocked: false),
      LevelData(id: 5, title: 'Nivel 1', biome: 'Desierto', isUnlocked: false),
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

  // ── Sincronización con Supabase ─────────────────────────────────
  /// Carga datos reales del alumno desde la nube.
  /// Se llama después del login para que todas las pantallas
  /// (que leen de GameState) muestren datos correctos.
  Future<void> syncFromSupabase(String studentId) async {
    _studentId = studentId;
    final client = Supabase.instance.client;

    try {
      // 1. Cargar niveles desde Supabase
      final levelsResult = await client
          .from('levels')
          .select()
          .eq('is_active', true)
          .order('order_index');

      if (levelsResult.isNotEmpty) {
        // Obtener progreso para saber cuáles desbloquear
        final progressResult = await client
            .from('student_progress')
            .select('level_id, stars_earned')
            .eq('student_id', studentId);

        final progressMap = <String, int>{};
        for (final row in progressResult) {
          progressMap[row['level_id'].toString()] = row['stars_earned'] as int;
        }

        final syncedLevels = <LevelData>[];
        for (final json in levelsResult) {
          final id = json['id'] as int;
          final title = json['title'] as String? ?? 'Nivel $id';
          final biome = json['biome'] as String? ?? title;
          // El nivel 0 siempre desbloqueado; los demás si completaste el anterior
          final isUnlocked = id == 0 ||
              (progressMap.containsKey((id - 1).toString()) &&
               (progressMap[(id - 1).toString()] ?? 0) > 0);
          syncedLevels.add(LevelData(id: id, title: title, biome: biome, isUnlocked: isUnlocked));
        }

        _levels = syncedLevels;
        _saveLevels();

        // Actualizar estrellas
        _levelStars = progressMap;
      } else {
        // Fallback a los 6 biomas/niveles por defecto si no hay en la nube
        final progressResult = await client
            .from('student_progress')
            .select('level_id, stars_earned')
            .eq('student_id', studentId);

        final progressMap = <String, int>{};
        for (final row in progressResult) {
          progressMap[row['level_id'].toString()] = row['stars_earned'] as int;
        }
        
        _levels = [
          LevelData(id: 0, title: 'Nivel 1', biome: 'Ciudad', isUnlocked: true),
          LevelData(id: 1, title: 'Nivel 1', biome: 'Manglar', isUnlocked: progressMap.containsKey('0') && progressMap['0']! > 0),
          LevelData(id: 2, title: 'Nivel 1', biome: 'Arrecife', isUnlocked: progressMap.containsKey('1') && progressMap['1']! > 0),
          LevelData(id: 3, title: 'Nivel 1', biome: 'Bosque', isUnlocked: progressMap.containsKey('2') && progressMap['2']! > 0),
          LevelData(id: 4, title: 'Nivel 1', biome: 'Selva', isUnlocked: progressMap.containsKey('3') && progressMap['3']! > 0),
          LevelData(id: 5, title: 'Nivel 1', biome: 'Desierto', isUnlocked: progressMap.containsKey('4') && progressMap['4']! > 0),
        ];
        _levelStars = progressMap;
        _saveLevels();
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
              iconCodePoint: (iconMap[iconName] ?? Icons.card_giftcard).codePoint,
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
      }

      // 5. Recalcular estrellas totales
      _recalculateTotalStars();

    } catch (e) {
      // Si falla la sync, GameState sigue funcionando con datos locales
      debugPrint('⚠️ Error sincronizando con Supabase: $e');
    }
  }
}
