import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../teacher_service.dart';

/// Implementación local del servicio de maestro.
/// Usa SharedPreferences + datos mock para la demo.
class LocalTeacherService implements TeacherService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Grupos ───────────────────────────────────────────────────────────
  @override
  Future<List<GroupModel>> getGroups() async {
    final prefs = await _getPrefs();
    final json = prefs.getString('teacher_groups');
    if (json != null) {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((e) => GroupModel.fromJson(e)).toList();
    }
    // Defaults para la demo
    final defaults = [
      GroupModel(id: 'g1', teacherId: 'teacher_demo', name: 'Grupo 4A', code: 'ECO-4A', createdAt: DateTime.now()),
      GroupModel(id: 'g2', teacherId: 'teacher_demo', name: 'Grupo 4B', code: 'ECO-4B', createdAt: DateTime.now()),
      GroupModel(id: 'g3', teacherId: 'teacher_demo', name: 'Grupo 5A', code: 'ECO-5A', createdAt: DateTime.now()),
    ];
    await prefs.setString('teacher_groups', jsonEncode(defaults.map((e) => e.toJson()).toList()));
    return defaults;
  }

  @override
  Future<GroupModel> createGroup(String name) async {
    final prefs = await _getPrefs();
    final groups = await getGroups();
    final code = 'ECO-${name.replaceAll(' ', '').substring(0, name.length > 3 ? 3 : name.length).toUpperCase()}';
    final newGroup = GroupModel(
      id: 'g${DateTime.now().millisecondsSinceEpoch}',
      teacherId: 'teacher_demo',
      name: name,
      code: code,
      createdAt: DateTime.now(),
    );
    groups.add(newGroup);
    await prefs.setString('teacher_groups', jsonEncode(groups.map((e) => e.toJson()).toList()));
    return newGroup;
  }

  @override
  Future<List<UserModel>> getStudentsInGroup(String groupId) async {
    final prefs = await _getPrefs();
    final json = prefs.getString('group_students_$groupId');
    if (json != null) {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((e) => UserModel.fromJson(e)).toList();
    }
    // Mock students para la demo
    return [
      UserModel(id: 's1', name: 'Juan Pérez', role: UserRole.student, createdAt: DateTime.now()),
      UserModel(id: 's2', name: 'Ana López', role: UserRole.student, createdAt: DateTime.now()),
      UserModel(id: 's3', name: 'Carlos Méndez', role: UserRole.student, createdAt: DateTime.now()),
      UserModel(id: 's4', name: 'Sofía Ramírez', role: UserRole.student, createdAt: DateTime.now()),
    ];
  }

  @override
  Future<void> addStudentToGroup(String groupId, String studentName) async {
    final prefs = await _getPrefs();
    final students = await getStudentsInGroup(groupId);
    students.add(UserModel(
      id: 's${DateTime.now().millisecondsSinceEpoch}',
      name: studentName,
      role: UserRole.student,
      createdAt: DateTime.now(),
    ));
    await prefs.setString(
      'group_students_$groupId',
      jsonEncode(students.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> removeStudentFromGroup(String groupId, String studentId) async {
    final prefs = await _getPrefs();
    final students = await getStudentsInGroup(groupId);
    students.removeWhere((s) => s.id == studentId);
    await prefs.setString(
      'group_students_$groupId',
      jsonEncode(students.map((e) => e.toJson()).toList()),
    );
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
    return [];
  }

  @override
  Future<void> addLevel(String title) async {
    final prefs = await _getPrefs();
    final levels = await getLevels();
    final newId = levels.isEmpty ? 0 : levels.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    levels.add(LevelModel(id: newId, title: title, orderIndex: newId, isUnlocked: true));
    await prefs.setString(
      'dynamic_levels',
      jsonEncode(levels.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> setLevelActive(int levelId, bool isActive) async {
    final prefs = await _getPrefs();
    final levels = await getLevels();
    final updated = levels.map((l) {
      if (l.id == levelId) return l.copyWith(isActive: isActive);
      return l;
    }).toList();
    await prefs.setString(
      'dynamic_levels',
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  // ── Recompensas ──────────────────────────────────────────────────────
  @override
  Future<List<RewardModel>> getRewards() async {
    final prefs = await _getPrefs();
    final json = prefs.getString('dynamic_rewards');
    if (json != null) {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((e) => RewardModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> addReward(RewardModel reward) async {
    final prefs = await _getPrefs();
    final rewards = await getRewards();
    rewards.add(reward);
    await prefs.setString(
      'dynamic_rewards',
      jsonEncode(rewards.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> removeReward(String rewardId) async {
    final prefs = await _getPrefs();
    final rewards = await getRewards();
    rewards.removeWhere((r) => r.id == rewardId);
    await prefs.setString(
      'dynamic_rewards',
      jsonEncode(rewards.map((e) => e.toJson()).toList()),
    );
  }

  // ── Progreso / Analytics ─────────────────────────────────────────────
  @override
  Future<Map<String, Map<String, int>>> getGroupProgress(String groupId) async {
    // En la demo, retornamos datos mock
    return {
      'Juan Pérez': {'0': 3, '1': 2, '2': 1},
      'Ana López': {'0': 3, '1': 3},
      'Carlos Méndez': {'0': 2},
      'Sofía Ramírez': {'0': 3, '1': 3, '2': 3, '3': 2},
    };
  }

  @override
  Future<List<QuizAttemptModel>> getStudentAttempts(String studentId) async {
    // En la demo, retornamos vacío
    return [];
  }
}
