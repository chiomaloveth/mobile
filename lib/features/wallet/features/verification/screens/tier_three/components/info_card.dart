import 'package:flutter/material.dart';


class InfoCard extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final bool isCompact;

  const InfoCard({super.key, required this.icon, this.title, required this.description, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B00).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                ],
                Text(description, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}