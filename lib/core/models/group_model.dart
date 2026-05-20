/// Modelo de grupo escolar.
class GroupModel {
  final String id;
  final String teacherId;
  final String name;       // "Grupo 4A"
  final String code;       // "ECO-4A" — el código que usa el alumno
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.code,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacher_id': teacherId,
        'name': name,
        'code': code,
        'created_at': createdAt.toIso8601String(),
      };

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json['id'] ?? '',
        teacherId: json['teacher_id'] ?? '',
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}
