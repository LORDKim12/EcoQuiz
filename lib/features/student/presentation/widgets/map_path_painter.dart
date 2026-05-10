import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MapPathPainter extends CustomPainter {
  final List<Offset> points;
  final Color pathColor;
  final double strokeWidth;

  MapPathPainter({
    required this.points,
    this.pathColor = Colors.white,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = pathColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // To make it dashed, we need to draw path segments
    const double dashWidth = 20.0;
    const double dashSpace = 15.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      
      double distance = (p2 - p1).distance;
      double dashCount = distance / (dashWidth + dashSpace);
      
      final double dx = (p2.dx - p1.dx) / dashCount;
      final double dy = (p2.dy - p1.dy) / dashCount;

      double startX = p1.dx;
      double startY = p1.dy;

      while (distance >= 0) {
        final endX = startX + dx * (dashWidth / (dashWidth + dashSpace));
        final endY = startY + dy * (dashWidth / (dashWidth + dashSpace));

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

        startX += dx;
        startY += dy;
        distance -= (dashWidth + dashSpace);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapPathPainter oldDelegate) {
    return oldDelegate.points != points ||
           oldDelegate.pathColor != pathColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
