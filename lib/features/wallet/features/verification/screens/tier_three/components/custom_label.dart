import 'package:flutter/material.dart';

import '../../../../../../../utilities/constants/app_colors.dart';

class CustomLabel extends StatelessWidget {
  final String text;

  const CustomLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}