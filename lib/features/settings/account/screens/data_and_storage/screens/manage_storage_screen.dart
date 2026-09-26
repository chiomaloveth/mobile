import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../../../../theme/provider/theme_provider.dart';

// ── Screen ─────────────────────────────────────────────────────────────────
class ManageStorageScreen extends ConsumerWidget {
  const ManageStorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system && systemBrightness == Brightness.dark);

    final Color bg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF5F0);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(AppColors.gradientColorsTwo),
                  Color(AppColors.gradientColorsOne),
                ],
              ) : null,
              color: isDark ? null : AppTheme.scaffoldBg(isDark),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Manage Storage',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2A3A) : const Color(0xFFE8F4FD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storage_outlined,
                    size: 40,
                    color: isDark ? const Color(0xFF6AADDB) : const Color(0xFF1A6FA0),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Storage Management',
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Detailed storage management and cleanup tools are coming soon. Your app data is automatically managed for optimal performance.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: subTextColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2A3A) : const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark ? const Color(0xFF6AADDB) : const Color(0xFF1A6FA0),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can clear app cache from your device settings to free up space.',
                          style: GoogleFonts.poppins(
                            color: isDark ? const Color(0xFF6AADDB) : const Color(0xFF1A6FA0),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
