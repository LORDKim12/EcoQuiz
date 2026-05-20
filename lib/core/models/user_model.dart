/// Roles de usuario en EcoQuiz.
enum UserRole { student, teacher }

/// Modelo de usuario genérico.
/// Funciona para autenticación y como base para Student/Teacher.
class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    this.email = '',
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'] ?? 'Explorador',
        email: json['email'] ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => UserRole.student,
        ),
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  UserModel copyWith({String? name, String? email}) => UserModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role,
        createdAt: createdAt,
      );
}
