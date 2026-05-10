import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/encyclopedia_card.dart';

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
                    Column(
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
                          '23 de 60 descubiertos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textDark,
                                fontSize: 18,
                              ),
                        ),
                      ],
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
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.55, // Adjusted to prevent overflow on small screens
                  children: _showAnimals ? _buildAnimalCards() : _buildPlantCards(),
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

  List<Widget> _buildAnimalCards() {
    return [
      EncyclopediaCard(
        title: 'Jaguar',
        subtitle: 'Panthera onca',
        imagePath: 'assets/images/card_jaguar.png',
        number: '#001',
        typeIcon: Icons.pets,
        themeColor: const Color(0xFF2980B9), // Blue border
        tags: [
          CardTag(label: 'Selva', bgColor: const Color(0xFFFDEBD0), textColor: AppColors.textBrown),
          CardTag(label: 'Vulnerable', bgColor: const Color(0xFFFADBD8), textColor: const Color(0xFFC0392B)),
        ],
      ),
      EncyclopediaCard(
        title: 'Ajolote',
        subtitle: 'Ambystoma mexicanum',
        imagePath: 'assets/images/card_ajolote.png',
        number: '#012',
        typeIcon: Icons.water_drop,
        themeColor: const Color(0xFF873600), // Brown border
        tags: [
          CardTag(label: 'Lago', bgColor: const Color(0xFFFDEBD0), textColor: AppColors.textBrown),
          CardTag(label: 'Peligro Crítico', bgColor: const Color(0xFFFADBD8), textColor: const Color(0xFFC0392B)),
        ],
      ),
      const LockedEncyclopediaCard(),
      const LockedEncyclopediaCard(),
    ];
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
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
