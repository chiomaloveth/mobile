import 'package:flutter/material.dart';

class InstructionsCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<String> items;
  final bool showBullets;

  const InstructionsCard({super.key, required this.icon, required this.title, required this.items, this.showBullets = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBullets)
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 10),
                    child: Icon(Icons.circle, size: 6, color: const Color(0xFFFF6B00).withOpacity(0.6)),
                  ),
                Expanded(
                  child: Text(item, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.4)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
