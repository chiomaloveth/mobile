import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../../../../theme/provider/theme_provider.dart';

// ── Provider ───────────────────────────────────────────────────────────────
enum PhotoQuality { auto, best, dataSaver }

final photoQualityProvider = StateProvider<PhotoQuality>((ref) => PhotoQuality.best);

// ── Screen ─────────────────────────────────────────────────────────────────
class PhotoQualityScreen extends ConsumerWidget {
  const PhotoQualityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(photoQualityProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system && systemBrightness == Brightness.dark);

    final Color bg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF5F0);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F2F2);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;
    final Color dividerColor =
        isDark ? Colors.white.withValues(alpha: 0.07) : Colors.grey.withValues(alpha: 0.2);

    final options = [
      _QualityOption(
        value: PhotoQuality.auto,
        title: 'Auto (recommended)',
        subtitle: 'Standard quality to save data',
      ),
      _QualityOption(
        value: PhotoQuality.best,
        title: 'Best quality',
        subtitle: 'HD quality, uses more data',
      ),
      _QualityOption(
        value: PhotoQuality.dataSaver,
        title: 'Data saver',
        subtitle: 'Lower quality, saves data',
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
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
                'Photo Quality',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Options card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: List.generate(options.length, (i) {
                    final opt = options[i];
                    final isLast = i == options.length - 1;
                    final isSelected = selected == opt.value;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => ref.read(photoQualityProvider.notifier).state = opt.value,
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.title,
                                        style: GoogleFonts.poppins(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        opt.subtitle,
                                        style: GoogleFonts.poppins(
                                          color: subTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF34C759),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            height: 0.5,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: dividerColor,
                          ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // Footer note
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'This setting affects photo quality when sent or received. Videos are not affected.',
                  style: GoogleFonts.poppins(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityOption {
  final PhotoQuality value;
  final String title;
  final String subtitle;

  const _QualityOption({
    required this.value,
    required this.title,
    required this.subtitle,
  });
}
