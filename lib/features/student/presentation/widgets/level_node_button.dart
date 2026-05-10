import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum LevelStatus { locked, current, completed }

class LevelNodeButton extends StatefulWidget {
  final int levelNumber;
  final LevelStatus status;
  final int stars; // 0 to 3
  final VoidCallback? onTap;

  const LevelNodeButton({
    super.key,
    required this.levelNumber,
    required this.status,
    this.stars = 0,
    this.onTap,
  });

  @override
  State<LevelNodeButton> createState() => _LevelNodeButtonState();
}

class _LevelNodeButtonState extends State<LevelNodeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.status != LevelStatus.locked) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.status != LevelStatus.locked) {
      _controller.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.status != LevelStatus.locked) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = widget.status == LevelStatus.locked;
    final bool isCurrent = widget.status == LevelStatus.current;

    // Node styles based on status
    final Color bgColor = isLocked
        ? Colors.white.withOpacity(0.5)
        : isCurrent
            ? const Color(0xFFF39C12) // Orange
            : const Color(0xFF0F5132); // Dark Green

    final Color borderColor = isLocked
        ? Colors.grey.withOpacity(0.5)
        : isCurrent
            ? const Color(0xFF873600) // Dark brown
            : const Color(0xFF000000); // Black

    final double nodeSize = isCurrent ? 80.0 : 70.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Main Node Circle
            Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: isLocked ? 4 : 6,
                ),
                boxShadow: isLocked
                    ? []
                    : [
                        BoxShadow(
                          color: borderColor.withOpacity(0.6),
                          offset: const Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: Center(
                child: isLocked
                    ? Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 32)
                    : Text(
                        '${widget.levelNumber}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: isCurrent ? 36 : 32,
                            ),
                      ),
              ),
            ),
            
            // Current Level "Play" Badge
            if (isCurrent)
              Positioned(
                top: 0,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.teacherPrimary, // Light blue
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                ),
              ),

            // Stars for completed levels
            if (widget.status == LevelStatus.completed)
              Positioned(
                bottom: -10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Icon(
                      index < widget.stars ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF1C40F), // Gold
                      size: 20,
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
