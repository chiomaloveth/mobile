import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class FinanceGroupOverviewTab extends ConsumerWidget {
  const FinanceGroupOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        children: [
          // Total Pool card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardBg(isDark),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pool Value',
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                        fontSize: 13,
                      ),
                    ),
                    Icon(Icons.currency_exchange,
                        color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                        size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '₦250,000',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Cycle Progress',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 2 / 5,
                    backgroundColor: AppColors.progressTrack,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accentOrange),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cycle 2 of 5',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Next Payout card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardBg(isDark),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.scaffoldBg(isDark),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.calendar_today_outlined,
                          color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                          size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Payout',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'May 15, 2026',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Recipient',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adetola Johnson',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Your Position card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardBg(isDark),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.scaffoldBg(isDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.trending_up,
                      color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                      size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Position',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '#1 in payout order',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.infoGreenBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.infoGreenBorder, width: 1),
                  ),
                  child: Text(
                    'Received',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bottom two cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Contribution',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₦50,000',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Per Monthly',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Members',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '5',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '4 active',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
