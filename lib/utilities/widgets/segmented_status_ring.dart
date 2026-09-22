import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws segmented arcs around a circular avatar.
/// Each segment = one status update.
/// Green = unseen, grey = seen.
class SegmentedStatusRing extends StatelessWidget {
  final Widget child;
  final int totalSegments;
  final int seenCount; // how many have been seen (grey)
  final double radius; // outer radius of the ring
  final double strokeWidth;
  final double gap; // gap in degrees between segments

  const SegmentedStatusRing({
    super.key,
    required this.child,
    required this.totalSegments,
    required this.seenCount,
    this.radius = 36.0,
    this.strokeWidth = 2.5,
    this.gap = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSegments == 0) return child;

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(radius * 2, radius * 2),
            painter: _SegmentPainter(
              totalSegments: totalSegments,
              seenCount: seenCount,
              strokeWidth: strokeWidth,
              gapDegrees: gap,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SegmentPainter extends CustomPainter {
  final int totalSegments;
  final int seenCount;
  final double strokeWidth;
  final double gapDegrees;

  static const Color _unseen = Color(0xFF00C853);
  static const Color _seen = Color(0xFF777777);

  _SegmentPainter({
    required this.totalSegments,
    required this.seenCount,
    required this.strokeWidth,
    required this.gapDegrees,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintRadius = size.width / 2 - strokeWidth / 2;

    final double gapRad = gapDegrees * math.pi / 180;
    final double totalGap = gapRad * totalSegments;
    final double segmentSweep = (2 * math.pi - totalGap) / totalSegments;

    // Start at the top (-π/2)
    double startAngle = -math.pi / 2;

    for (int i = 0; i < totalSegments; i++) {
      // Segments are ordered newest-first in the list.
      // First (totalSegments - seenCount) segments are unseen (green),
      // the rest are seen (grey).
      final bool isSeen = i >= (totalSegments - seenCount);

      final paint = Paint()
        ..color = isSeen ? _seen : _unseen
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: paintRadius),
        startAngle,
        segmentSweep,
        false,
        paint,
      );

      startAngle += segmentSweep + gapRad;
    }
  }

  @override
  bool shouldRepaint(_SegmentPainter old) =>
      old.totalSegments != totalSegments ||
      old.seenCount != seenCount ||
      old.strokeWidth != strokeWidth ||
      old.gapDegrees != gapDegrees;
}
