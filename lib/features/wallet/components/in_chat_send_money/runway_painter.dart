import 'package:flutter/material.dart';


const Color _kWhite = Colors.white;

class RunwayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2;

    // Runway perspective lines
    canvas.drawLine(const Offset(100, 0), Offset(0, size.height), paint);
    canvas.drawLine(const Offset(150, 0), Offset(250, size.height), paint);

    // Center dash lines
    final dashPaint = Paint()
      ..color = _kWhite
      ..strokeWidth = 4;

    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(125, i * 20.0),
        Offset(125, i * 20.0 + 10),
        dashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}