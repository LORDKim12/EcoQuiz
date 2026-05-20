/// Modelo de recompensa. Puro Dart, serializable.
/// Usa strings para icono y color en vez de tipos de Flutter.
class RewardModel {
  final String id;
  final String groupId; // FK al grupo (para BD)
  final String title;
  final String subtitle;
  final int cost;
  final String iconName;  // Nombre del icono Material (ej. 'face', 'lightbulb')
  final String colorHex;  // Color como hex string (ej. '#8E44AD')

  const RewardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.cost,
    this.groupId = '',
    this.iconName = 'card_giftcard',
    this.colorHex = '#F39C12',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'group_id': groupId,
        'title': title,
        'subtitle': subtitle,
        'cost': cost,
        'icon_name': iconName,
        'color_hex': colorHex,
      };

  factory RewardModel.fromJson(Map<String, dynamic> json) => RewardModel(
        id: json['id'] ?? '',
        groupId: json['group_id'] ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        cost: json['cost'] ?? 0,
        iconName: json['icon_name'] ?? 'card_giftcard',
        colorHex: json['color_hex'] ?? '#F39C12',
      );

  RewardModel copyWith({String? title, String? subtitle, int? cost}) =>
      RewardModel(
        id: id,
        groupId: groupId,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        cost: cost ?? this.cost,
        iconName: iconName,
        colorHex: colorHex,
      );
}
