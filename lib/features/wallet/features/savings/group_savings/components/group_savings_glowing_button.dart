import 'package:flutter/material.dart';

import '../../../../../../utilities/constants/app_colors.dart';

class GlowingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;

  const GlowingButton({Key? key, required this.text, this.onPressed, this.isEnabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ] : [],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF252528),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isEnabled ? AppColors.primaryRed.withOpacity(0.5) : Colors.transparent),
          ),
          elevation: 0,
        ),
        onPressed: isEnabled ? onPressed : null,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}