/// Modelo de tarjeta de enciclopedia. Puro Dart, serializable.
/// Reemplaza EncyclopediaCardData que usaba IconData y Color de Flutter.
class EncyclopediaCardModel {
  final int id;
  final String title;
  final String subtitle;
  final String imagePath; // Asset local o URL remota
  final String number;    // Ej. '#012'
  final String iconName;  // Nombre del icono Material (ej. 'water_drop')
  final String colorHex;  // Color como hex (ej. '#873600')

  const EncyclopediaCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.number,
    this.iconName = 'pets',
    this.colorHex = '#27AE60',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'image_path': imagePath,
        'number': number,
        'icon_name': iconName,
        'color_hex': colorHex,
      };

  factory EncyclopediaCardModel.fromJson(Map<String, dynamic> json) =>
      EncyclopediaCardModel(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        imagePath: json['image_path'] ?? '',
        number: json['number'] ?? '#000',
        iconName: json['icon_name'] ?? 'pets',
        colorHex: json['color_hex'] ?? '#27AE60',
      );
}
