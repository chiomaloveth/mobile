import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../theme/provider/theme_provider.dart';

// ── Provider ───────────────────────────────────────────────────────────────

enum BackupFrequency { off, daily, weekly, monthly }

final backupFrequencyProvider =
    StateProvider<BackupFrequency>((ref) => BackupFrequency.daily);

// ── Screen ─────────────────────────────────────────────────────────────────

class BackupFrequencyScreen extends ConsumerWidget {
  const BackupFrequencyScreen({super.key});

  static const _options = [
    (BackupFrequency.off, 'Off', 'No automatic backups'),
    (BackupFrequency.daily, 'Daily', 'Backup every day at 2:00 AM'),
    (BackupFrequency.weekly, 'Weekly', 'Backup every Sunday'),
    (BackupFrequency.monthly, 'Monthly', 'Backup on the 1st of each month'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(backupFrequencyProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? HexColor("#3A1D07") : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark ? const DecorationImage(
                  image: AssetImage("images/app_bar_gredient.png"),
                  fit: BoxFit.cover,
                ) : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: topPadding, left: 16, right: 40),
                          child: Icon(Icons.arrow_back,
                              size: 22, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding, left: 10),
                        child: Text(
                          'Backup Frequency',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg(isDark),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_options.length, (i) {
                final opt = _options[i];
                final isSelected = selected == opt.$1;
                final isLast = i == _options.length - 1;
                return Column(
                  children: [
                    InkWell(
                      onTap: () => ref
                          .read(backupFrequencyProvider.notifier)
                          .state = opt.$1,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt.$2,
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textPrimary(isDark),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    opt.$3,
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textSecondary(isDark),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34C759),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 18),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: AppTheme.dividerSubtle(isDark),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
