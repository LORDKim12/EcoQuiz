import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/game_state.dart';
import '../widgets/encyclopedia_card.dart';
import '../widgets/settings_bottom_sheet.dart';
import 'student_level_complete_screen.dart';

class StudentJournalScreen extends StatefulWidget {
  const StudentJournalScreen({super.key});

  @override
  State<StudentJournalScreen> createState() => _StudentJournalScreenState();
}

class _StudentJournalScreenState extends State<StudentJournalScreen> {
  bool _showAnimals = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _buildCustomAppBar(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enciclopedia',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Colección del Explorador',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // Progress Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEAE5), // Light pinkish orange
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.studentPrimary, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F5132), // Dark green
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    ValueListenableBuilder<List<int>>(
                      valueListenable: GameState.instance.unlockedCards,
                      builder: (context, unlocked, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PROGRESO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBrown.withOpacity(0.8),
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '${unlocked.length} de ${GameState.allCards.length} descubiertos',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.textDark,
                                    fontSize: 18,
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterTab(
                      'Animales',
                      Icons.pets,
                      _showAnimals,
                      () => setState(() => _showAnimals = true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFilterTab(
                      'Plantas',
                      Icons.eco_outlined,
                      !_showAnimals,
                      () => setState(() => _showAnimals = false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid of Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ValueListenableBuilder<List<int>>(
                  valueListenable: GameState.instance.unlockedCards,
                  builder: (context, unlocked, child) {
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.55,
                      children: _showAnimals ? _buildDynamicCards(unlocked) : _buildPlantCards(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.studentPrimary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? const Color(0xFF0F5132) : Colors.grey.shade400,
            width: 3,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withOpacity(0.5),
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? const Color(0xFF0F5132) : AppColors.textDark, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF0F5132) : AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicCards(List<int> unlockedIds) {
    return GameState.allCards.map((cardData) {
      if (unlockedIds.contains(cardData.id)) {
        return EncyclopediaCard(
          title: cardData.title,
          subtitle: cardData.subtitle,
          imagePath: cardData.imagePath,
          number: cardData.number,
          typeIcon: cardData.typeIcon,
          themeColor: cardData.themeColor,
          tags: [
            CardTag(label: 'Descubierto', bgColor: const Color(0xFFD6EAF8), textColor: const Color(0xFF2980B9)),
          ],
        );
      } else {
        return const LockedEncyclopediaCard();
      }
    }).toList();
  }

  List<Widget> _buildPlantCards() {
    return [
      const LockedEncyclopediaCard(),
      const LockedEncyclopediaCard(),
      const LockedEncyclopediaCard(),
      const LockedEncyclopediaCard(),
    ];
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.studentBorder,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
          Text(
            'EcoQuiz',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.studentBorder,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.studentBorder),
              onPressed: () => SettingsBottomSheet.show(context),
            ),
          ),
        ],
      ),
    );
  }
}
