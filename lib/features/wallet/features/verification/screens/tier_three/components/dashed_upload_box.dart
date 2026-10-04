import 'package:flutter/material.dart';

import 'dash_rec_painter.dart';

class DashedUploadBox extends StatelessWidget {
  final String title;
  final String subtitle;

  const DashedUploadBox({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedRectPainter(color: Colors.white.withOpacity(0.3)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, size: 42, color: const Color(0xFFFF6B00).withOpacity(0.8)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}