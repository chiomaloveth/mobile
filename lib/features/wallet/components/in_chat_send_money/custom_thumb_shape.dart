import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kOrange = Color(0xFFE68A00);
const Color _kWhite = Colors.white;

class CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(40, 30);

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        bool? isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        TextDirection? textDirection,
        double? value,
        double? textScaleFactor,
        Size? sizeWithOverflow}) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = _kOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromCenter(center: center, width: 34, height: 30);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '<>',
        style: GoogleFonts.poppins(
            color: _kWhite, fontSize: 10, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
  }
}