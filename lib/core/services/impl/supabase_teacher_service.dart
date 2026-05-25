import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../teacher_service.dart';

/// Implementación del servicio de maestro con Supabase.
class SupabaseTeacherService implements TeacherService {
  final _client = Supabase.instance.client;
  String? _teacherId;

  /// Establecer el ID del maestro actual (se llama después del login).
  void setTeacherId(String id) => _teacherId = id;

  /// Getter público para el ID del maestro actual.
  String? get teacherId => _teacherId;

  String get _tid {
    if (_teacherId == null) throw Exception('TeacherId no configurado.');
    return _teacherId!;
  }

  // ── Grupos ───────────────────────────────────────────────────────────
  @override
  Future<List<GroupModel>> getGroups() async {
    final result = await _client
        .from('groups')
        .select()
        .eq('teacher_id', _tid)
        .order('created_at');

    return result.map((json) => GroupModel.fromJson(json)).toList();
  }

  @override
  Future<GroupModel> createGroup(String name) async {
    // Generar código único basado en el nombre
    final code = 'ECO-${name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').substring(0, name.length > 3 ? 3 : name.length).toUpperCase()}';

    final result = await _client.from('groups').insert({
      'teacher_id': _tid,
      'name': name,
      'code': code,
    }).select().single();

    return GroupModel.fromJson(result);
  }

  @override
  Future<List<UserModel>> getStudentsInGroup(String groupId) async {
    final result = await _client
        .from('group_members')
        .select('profiles!inner(id, name, role, created_at)')
        .eq('group_id', groupId);

    return result.map((row) {
      final profile = row['profiles'];
      return UserModel(
        id: profile['id'],
        name: profile['name'],
        role: UserRole.student,
        createdAt: DateTime.tryParse(profile['created_at'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> addStudentToGroup(String groupId, String studentName) async {
    // Crear perfil
    final profile = await _client.from('profiles').insert({
      'name': studentName,
      'role': 'student',
      'hearts': 5,
    }).select().single();

    // Vincular al grupo
    await _client.from('group_members').insert({
      'group_id': groupId,
      'student_id': profile['id'],
    });
  }

  @override
  Future<void> removeStudentFromGroup(String groupId, String studentId) async {
    await _client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('student_id', studentId);
  }

  // ── Niveles ──────────────────────────────────────────────────────────
  @override
  Future<List<LevelModel>> getLevels() async {
    final result = await _client
        .from('levels')
        .select()
        .order('order_index');

    return result.map((json) => LevelModel.fromJson(json)).toList();
  }

  @override
  Future<void> addLevel(String title) async {
    final levels = await getLevels();
    final nextOrder = levels.isEmpty ? 0 : levels.length;

    await _client.from('levels').insert({
      'title': title,
      'biome': title.toLowerCase(),
      'order_index': nextOrder,
      'is_active': true,
    });
  }

  @override
  Future<void> setLevelActive(int levelId, bool isActive) async {
    await _client
        .from('levels')
        .update({'is_active': isActive})
        .eq('id', levelId);
  }

  // ── Recompensas ──────────────────────────────────────────────────────
  @override
  Future<List<RewardModel>> getRewards({String? groupId}) async {
    String? targetGroupId = groupId;
    
    if (targetGroupId == null) {
      final groups = await getGroups();
      if (groups.isEmpty) return [];
      targetGroupId = groups.first.id;
    }
    
    final response = await _client.from('rewards').select().eq('group_id', targetGroupId);

    return (response as List).map((json) => RewardModel.fromJson(json)).toList();
  }

  @override
  Future<void> addReward(RewardModel reward) async {
    var groups = await getGroups();
    // Si no hay grupos, crear uno automáticamente para poder guardar rewards
    if (groups.isEmpty) {
      await createGroup('Grupo Principal');
      groups = await getGroups();
      if (groups.isEmpty) return;
    }

    await _client.from('rewards').insert({
      'group_id': groups.first.id,
      'title': reward.title,
      'subtitle': reward.subtitle,
      'cost': reward.cost,
      'icon_name': reward.iconName,
      'color_hex': reward.colorHex,
    });
  }

  @override
  Future<void> removeReward(String rewardId) async {
    await _client.from('rewards').delete().eq('id', rewardId);
  }

  // ── Progreso / Analytics ─────────────────────────────────────────────
  @override
  Future<Map<String, Map<String, int>>> getGroupProgress(String groupId) async {
    // Obtener alumnos del grupo con su progreso
    final members = await getStudentsInGroup(groupId);
    final progress = <String, Map<String, int>>{};

    for (final student in members) {
      final result = await _client
          .from('student_progress')
          .select('level_id, stars_earned')
          .eq('student_id', student.id);

      final studentProgress = <String, int>{};
      for (final row in result) {
        studentProgress[row['level_id'].toString()] = row['stars_earned'] as int;
      }
      progress[student.name] = studentProgress;
    }

    return progress;
  }

  @override
  Future<Map<String, dynamic>> getGroupStats(String groupId) async {
    final members = await getStudentsInGroup(groupId);
    final studentCount = members.length;

    final levels = await getLevels();
    final activeLevelsCount = levels.where((l) => l.isActive).length;

    final progress = await getGroupProgress(groupId);
    
    final levelBiomeMap = <String, String>{};
    for (final l in levels) {
      levelBiomeMap[l.id.toString()] = l.biome;
    }

    final biomeStarsSum = <String, int>{};
    int totalStarsEarnedAll = 0;

    for (final studentName in progress.keys) {
      final studentStats = progress[studentName]!;
      for (final entry in studentStats.entries) {
        final levelId = entry.key;
        final stars = entry.value;
        totalStarsEarnedAll += stars;

        final biome = levelBiomeMap[levelId] ?? 'Desconocido';
        biomeStarsSum[biome] = (biomeStarsSum[biome] ?? 0) + stars;
      }
    }

    final biomeAverages = <Map<String, dynamic>>[];
    for (final l in levels) {
      final biome = l.biome;
      final sum = biomeStarsSum[biome] ?? 0;
      final avg = studentCount > 0 ? sum / studentCount : 0.0;
      
      if (l.isActive) {
         biomeAverages.add({
           'biome': biome,
           'label': l.title,
           'avgStars': avg,
         });
      }
    }

    final overallAverage = studentCount > 0 ? totalStarsEarnedAll / studentCount : 0.0;

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final activityLogs = await _client
        .from('activity_log')
        .select('student_id, stars_added')
        .gte('created_at', startOfWeek.toIso8601String());

    final ranking = <Map<String, dynamic>>[];
    for (final m in members) {
      int weeklyStars = 0;
      for (final log in activityLogs) {
        if (log['student_id'] == m.id) {
          weeklyStars += (log['stars_added'] as int);
        }
      }
      ranking.add({
        'name': m.name,
        'stars': weeklyStars,
      });
    }

    ranking.sort((a, b) => (b['stars'] as int).compareTo(a['stars'] as int));

    return {
      'studentCount': studentCount,
      'activeLevelsCount': activeLevelsCount,
      'overallAverage': overallAverage,
      'biomeAverages': biomeAverages,
      'ranking': ranking,
    };
  }

  @override
  Future<List<QuizAttemptModel>> getStudentAttempts(String studentId) async {
    final result = await _client
        .from('quiz_attempts')
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .limit(100);

    return result.map((json) => QuizAttemptModel.fromJson(json)).toList();
  }
}
