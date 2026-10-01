import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/group_chat/screens/create_new_group_screen.dart';
// Finance group creation is temporarily disabled but kept recoverable.
// import 'package:qik_talk/features/chat/group_chat/screens/finance_group/finance_group_modal.dart';
// import 'package:qik_talk/features/chat/group_chat/screens/finance_group/finance_group_info_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class GroupTypeSelectionScreen extends ConsumerWidget {
  const GroupTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [HexColor('#3A1D07'), HexColor('#171516')],
                  )
                : null,
            color: isDark ? null : AppColors.lightNavBar,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Create Group',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            /* Finance group creation temporarily disabled.
            _GroupTypeCard(
              iconPath: 'images/finance_group.png',
              iconBgColor: const Color(0xFFFB8830),
              title: 'Finance',
              subtitle:
                  'Savings & contribution group\nfor managing collective funds',
              onTap: () {
                showFinanceGroupModal(context, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FinanceGroupInfoScreen(),
                    ),
                  );
                });
              },
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            */
            _GroupTypeCard(
              iconPath: 'images/family_group.png',
              iconBgColor: const Color(0xFF1A7F4B),
              title: 'Family & Friends',
              subtitle: 'Social group for staying\nconnected with loved ones',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateGroupStep1Screen(),
                  ),
                );
              },
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTypeCard extends StatelessWidget {
  final String iconPath;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _GroupTypeCard({
    required this.iconPath,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(iconPath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.iconColorSubtle(isDark),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
