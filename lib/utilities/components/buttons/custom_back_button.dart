import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class CustomBackButton extends ConsumerStatefulWidget {
  final BuildContext buildContext;
  const CustomBackButton({super.key, required this.buildContext});

  @override
  ConsumerState<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends ConsumerState<CustomBackButton> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentTheme == ThemeMode.dark ||
        (currentTheme == ThemeMode.system && systemBrightness == Brightness.dark);
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
      ),
      onPressed: () => Navigator.pop(widget.buildContext),
    );
  }
}
