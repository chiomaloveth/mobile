import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/finance_group_detail_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class FinanceGroupSuccessScreen extends ConsumerWidget {
  final String groupName;

  const FinanceGroupSuccessScreen({
    super.key,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              24, 60, 24, 24 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.35),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Group Created\nSuccessfully!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your group has been created.\nInvitations have been sent to all members.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // What's next card
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
                    Text(
                      "What's next?",
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...[
                      'Members will receive group invitations',
                      'You can start chatting once they join',
                      'Manage your group settings anytime',
                    ].map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p,
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? Colors.white70
                                      : AppTheme.textSecondary(isDark),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              CustomButtonTwo(
                title: 'Open Group Chat',
                isLoading: false,
                hasMargin: false,
                onClick: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FinanceGroupDetailScreen(groupName: groupName),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(isDark),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'View All Groups',
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
