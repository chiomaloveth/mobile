import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class FinanceGroupActivityTab extends ConsumerWidget {
  const FinanceGroupActivityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Center(
      child: Text(
        'Activity coming soon',
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
          fontSize: 14,
        ),
      ),
    );
  }
}
