import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class CustomSwitchOne extends StatelessWidget {
  final bool value;
  final Function(bool) onChange;
  final bool isDark;
  const CustomSwitchOne({
    super.key,
    required this.value,
    required this.onChange,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.7,
      child: Switch(
        inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
        value: value,
        onChanged: onChange,
        activeTrackColor: isDark ? HexColor("#DEDEDE") : Colors.greenAccent,
        activeColor: isDark ? Colors.black : Colors.white,
      ),
    );
  }
}
