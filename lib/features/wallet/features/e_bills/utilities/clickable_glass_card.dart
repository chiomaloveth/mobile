import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import '../../../../../utilities/constants/app_colors.dart';

class ClickableGlassCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? customBorderRadius;
  final VoidCallback? onTap;

  const ClickableGlassCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.padding = const EdgeInsets.all(20),
    this.customBorderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = customBorderRadius ?? BorderRadius.circular(16);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.buttonBrown.withOpacity(0.4)
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              borderRadius: radius,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryOrange
                    : (isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.12)),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}