import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../teacher_service.dart';

/// Implementación del servicio de maestro con Supabase.
class SupabaseTeacherService implements TeacherService {
  final _client = Supabase.instance.client;
  String? _teacherId;

  /// Establecer el ID del maestro actual (se llama después del login).
  void setTeacherId(String id) => _teacherId = id;

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
  Future<List<RewardModel>> getRewards() async {
    // Obtener el primer grupo del maestro
    final groups = await getGroups();
    if (groups.isEmpty) return [];

    final result = await _client
        .from('rewards')
        .select()
        .eq('group_id', groups.first.id);

    return result.map((json) => RewardModel.fromJson(json)).toList();
  }

  @override
  Future<void> addReward(RewardModel reward) async {
    final groups = await getGroups();
    if (groups.isEmpty) return;

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
