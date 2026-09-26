import 'package:flutter/material.dart';

class ThemeAccentColorSelectionCard extends StatelessWidget {
  final Color color;
  final Color selectedColor;
  final VoidCallback onClick;
  final bool isDark;
  const ThemeAccentColorSelectionCard({super.key, required this.color, required this.selectedColor, required this.onClick, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: 55,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: color == selectedColor ? isDark ? Colors.white : Colors.black : Colors.transparent, width: 1.5)
      ),
      child: MaterialButton(onPressed: onClick),
    );
  }
}
