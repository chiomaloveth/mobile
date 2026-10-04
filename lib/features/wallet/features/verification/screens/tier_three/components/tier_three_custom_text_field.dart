import 'package:flutter/material.dart';

import '../../../../../../../utilities/constants/app_colors.dart';

class TierThreeCustomTextField extends StatelessWidget {
  final String hintText;
  final String? initialValue;

  const TierThreeCustomTextField({super.key, required this.hintText, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05), // Glass fill
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.5), // Brand Orange
        ),
      ),
    );
  }
}