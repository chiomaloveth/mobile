import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class FinanceGroupMemberProfileScreen extends ConsumerWidget {
  final String name;
  final bool isYou;
  final bool isAdmin;
  final String status;
  final bool payoutReceived;

  const FinanceGroupMemberProfileScreen({
    super.key,
    required this.name,
    required this.isYou,
    required this.isAdmin,
    required this.status,
    this.payoutReceived = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
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
            color: isDark ? null : AppTheme.scaffoldBg(isDark),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Member Profile',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.account_balance_wallet_outlined,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                    size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                    size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.scaffoldBg(isDark),
                    child: Text(
                      name[0],
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isYou ? 'Admin' : 'Member',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member of Monthly Savings Circle',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Finance stats label
            Text(
              'FINANCE STATS',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // Position + Status
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg(isDark),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Position',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isYou ? '#1' : '#2',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg(isDark),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up,
                                color: AppColors.primaryGreen, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          status,
                          style: GoogleFonts.poppins(
                            color: status == 'paid'
                                ? AppColors.primaryGreen
                                : AppColors.warningText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Total Contributed
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Contributed',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₦100,000',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Payout Received (only for you)
            if (payoutReceived) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(isDark),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up,
                            color: AppColors.primaryGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Payout Received',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₦250,000',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Contact Information
            Text(
              'CONTACT INFORMATION',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: '+234 XXX XXX XXXX',
                    showDivider: true,
                    isDark: isDark,
                  ),
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: isYou
                        ? 'hilaryodogwu@gmail.com'
                        : 'adetola.johnson@gmail.com',
                    showDivider: false,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // Actions (admin only, not for yourself)
            if (isAdmin && !isYou) ...[
              const SizedBox(height: 20),
              Text(
                'ACTIONS',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(isDark),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.chat_bubble_outline,
                      iconColor: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                      title: 'Send Message',
                      subtitle: 'Start a conversation',
                      showDivider: true,
                      isDark: isDark,
                      onTap: () {},
                    ),
                    _ActionRow(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: AppColors.warningText,
                      title: 'Make Admin',
                      subtitle: 'Grant admin privileges',
                      showDivider: true,
                      isDark: isDark,
                      onTap: () {},
                    ),
                    _ActionRow(
                      icon: Icons.person_remove_outlined,
                      iconColor: AppColors.errorRed,
                      title: 'Remove Member',
                      subtitle: 'Remove from group',
                      titleColor: AppColors.errorRed,
                      showDivider: false,
                      isDark: isDark,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppTheme.cardBg(isDark),
                            title: Text(
                              'Remove Member',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to remove $name from the group?',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                                fontSize: 13,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel',
                                    style: GoogleFonts.poppins(
                                        color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark))),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Remove',
                                    style: GoogleFonts.poppins(
                                        color: AppColors.errorRed,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;
  final bool isDark;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.showDivider,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon,
                  color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                  size: 20),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
              height: 1,
              color: Colors.white.withOpacity(0.05),
              indent: 16,
              endIndent: 16),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final bool showDivider;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleColor,
    required this.showDivider,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: titleColor ??
                            (isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
              height: 1,
              color: Colors.white.withOpacity(0.05),
              indent: 16,
              endIndent: 16),
      ],
    );
  }
}
