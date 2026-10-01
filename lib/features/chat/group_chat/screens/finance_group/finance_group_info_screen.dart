import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/finance_group_setup_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';

class FinanceGroupInfoScreen extends ConsumerWidget {
  const FinanceGroupInfoScreen({super.key});

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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HexColor('#3A1D07'), HexColor('#171516')],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Finance Group',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          36 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Warning banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.warningBg : const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.warningBorder : const Color(0xFFFFD699),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline,
                      color: isDark ? AppColors.warningText : const Color(0xFFD97706), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important: Read Before Continuing',
                          style: GoogleFonts.poppins(
                            color: isDark ? AppColors.warningText : const Color(0xFFD97706),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Finance groups involve real money transactions. Please review the following carefully.',
                          style: GoogleFonts.poppins(
                            color: isDark ? AppColors.warningText : const Color(0xFFD97706),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Info cards
            _InfoCard(
              icon: Icons.account_balance_wallet_outlined,
              iconBgColor: const Color(0xFF1A3A5C),
              iconColor: const Color(0xFF5B98D9),
              title: 'Wallet Connection Required',
              description:
                  'Your wallet will be linked to this group. This connection is permanent and cannot be undone or changed later.',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.swap_vert,
              iconBgColor: const Color(0xFF3A2800),
              iconColor: const Color(0xFFD4A017),
              title: 'Automatic Deductions',
              description:
                  'Contributions will be automatically deducted from your wallet based on the agreed schedule. Make sure you have sufficient balance.',
              detailRows: const [
                _DetailRow(
                    label: 'Deduction happens:',
                    value: 'On scheduled dates'),
                _DetailRow(
                    label: 'Notification:', value: '24 hours before'),
              ],
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.calendar_month_outlined,
              iconBgColor: const Color(0xFF0D2E1A),
              iconColor: AppColors.primaryGreen,
              title: 'Structured Payout System',
              description:
                  'Members receive payouts in a predetermined order. Each member gets their turn to receive the pooled contributions. Once the cycle starts, the payout order cannot be changed.',
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Key points
            Text(
              'Key Points to Remember',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              'Finance groups cannot be downgraded to other types',
              'All members must consent to wallet linkage and auto-deductions',
              'Failed deductions may result in penalties or removal from the group',
              'Group settings are locked once the first cycle begins',
            ].map((point) => _BulletPoint(text: point, isDark: isDark)),
            const SizedBox(height: 32),

            // Buttons
            CustomButtonTwo(
              title: 'I understand, Continue',
              isLoading: false,
              hasMargin: false,
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FinanceGroupSetupScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String description;
  final List<_DetailRow>? detailRows;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.description,
    this.detailRows,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = AppTheme.cardBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);
    final Color innerCardBg = isDark ? const Color(AppColors.primaryBackgroundColor) : const Color(0xFFE8DDD0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (detailRows != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: innerCardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: detailRows!
                    .map(
                      (row) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              row.label,
                              style: GoogleFonts.poppins(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              row.value,
                              style: GoogleFonts.poppins(
                                color: textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final bool isDark;
  const _BulletPoint({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppTheme.textSecondary(isDark);
    final Color bulletColor = isDark ? Colors.white54 : const Color(0xFF6B6B6B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: bulletColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}