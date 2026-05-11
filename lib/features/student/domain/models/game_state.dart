import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class GameState {
  static final GameState instance = GameState._internal();
  GameState._internal();

  final ValueNotifier<List<int>> unlockedCards = ValueNotifier<List<int>>([0, 4]);
  
  final ValueNotifier<List<bool>> unlockedLevels = ValueNotifier<List<bool>>([
    true, false, false, false, false, false,
  ]);

  final ValueNotifier<int> hearts = ValueNotifier<int>(5);

  SharedPreferences? _prefs;

  // Cargar datos guardados
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Cargar tarjetas
    final String? cardsJson = _prefs?.getString('unlocked_cards');
    if (cardsJson != null) {
      unlockedCards.value = List<int>.from(jsonDecode(cardsJson));
    }

    // Cargar niveles
    final String? levelsJson = _prefs?.getString('unlocked_levels');
    if (levelsJson != null) {
      unlockedLevels.value = List<bool>.from(jsonDecode(levelsJson));
    }

    // Cargar vidas
    final int? savedHearts = _prefs?.getInt('hearts');
    if (savedHearts != null) {
      hearts.value = savedHearts;
    }
  }

  void setLevelUnlocked(int index, bool isUnlocked) {
    final newList = List<bool>.from(unlockedLevels.value);
    newList[index] = isUnlocked;
    unlockedLevels.value = newList;
    _prefs?.setString('unlocked_levels', jsonEncode(newList));
  }

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
}
