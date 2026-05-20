/// Modelo de nivel/bioma. Puro Dart, sin dependencias de Flutter.
class LevelModel {
  final int id;
  final String title;
  final String biome;
  final int orderIndex;
  final bool isUnlocked;
  final bool isActive;

  const LevelModel({
    required this.id,
    required this.title,
    this.biome = '',
    this.orderIndex = 0,
    this.isUnlocked = false,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'biome': biome,
        'order_index': orderIndex,
        'is_unlocked': isUnlocked,
        'is_active': isActive,
      };

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
        id: json['id'],
        title: json['title'] ?? '',
        biome: json['biome'] ?? '',
        orderIndex: json['order_index'] ?? json['id'] ?? 0,
        isUnlocked: json['is_unlocked'] ?? json['isUnlocked'] ?? false,
        isActive: json['is_active'] ?? true,
      );

  LevelModel copyWith({bool? isUnlocked, bool? isActive, String? title}) =>
      LevelModel(
        id: id,
        title: title ?? this.title,
        biome: biome,
        orderIndex: orderIndex,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        isActive: isActive ?? this.isActive,
      );
}
