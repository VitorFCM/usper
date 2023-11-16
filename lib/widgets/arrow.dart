import 'package:flutter/material.dart';
import 'dart:math' as math;

class Arrow extends CustomPainter {
  final Offset p1;
  final Offset p2;

  Arrow({required this.p1, required this.p2});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    canvas.drawLine(p1, p2, paint);

    Path path = Path();
    final dX = p2.dx - p1.dx;
    final dY = p2.dy - p1.dy;
    final angle = math.atan2(dY, dX);

    const double arrowSize = 15;
    const double arrowAngle = 25 * math.pi / 180;

    path.moveTo(p2.dx - arrowSize * math.cos(angle - arrowAngle),
        p2.dy - arrowSize * math.sin(angle - arrowAngle));
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p2.dx - arrowSize * math.cos(angle + arrowAngle),
        p2.dy - arrowSize * math.sin(angle + arrowAngle));
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
