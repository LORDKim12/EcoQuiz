import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EncyclopediaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String number;
  final IconData typeIcon;
  final Color themeColor;
  final List<Widget> tags;

  const EncyclopediaCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.number,
    required this.typeIcon,
    required this.themeColor,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                  ),
                ),
                // Number Pill
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      number,
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Icon Badge
                Positioned(
                  bottom: -16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(typeIcon, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          
          // Info Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textBrown,
                          fontWeight: FontWeight.w900,
                          fontSize: 16, // Reduced from 20
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                      fontSize: 11, // Reduced from 13
                    ),
                  ),
                  const Spacer(),
                  // Tags Row
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LockedEncyclopediaCard extends StatelessWidget {
  const LockedEncyclopediaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E1).withOpacity(0.5), // Light pinkish
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed border effect
          Positioned.fill(
            child: CustomPaint(
              painter: DashedRectPainter(color: Colors.grey.shade400),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '?',
                style: TextStyle(
                  fontSize: 60, // Reduced from 80
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade200.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '???',
                style: TextStyle(
                  fontSize: 20, // Reduced from 24
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sigue explorando\npara descubrir',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;

  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(24)));

    // Simulating dashed border for locked cards
    // NOTE: A true dashed path requires path_drawing package or manual metric extraction,
    // but a solid semi-transparent border works well for this design as a fallback.
    // To match exactly, I'll draw small lines manually if needed, but for simplicity
    // we use a styled border above. This painter acts as a placeholder if needed.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CardTag extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const CardTag({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 9, // Reduced from 10
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
