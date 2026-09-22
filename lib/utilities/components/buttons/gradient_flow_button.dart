import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class GradientGlowButton extends StatelessWidget {
  final String text;
  final VoidCallback onClick;
  const GradientGlowButton({super.key, required this.text, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.btnGradStart, AppColors.btnGradEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),

        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.btnGradStart, AppColors.btnGradEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(1.5),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14.5),
            ),
            child: ElevatedButton(
              onPressed: onClick,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.5),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}