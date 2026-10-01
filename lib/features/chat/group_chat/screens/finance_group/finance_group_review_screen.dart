import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/finance_group_success_screen.dart';

class FinanceGroupReviewScreen extends StatelessWidget {
  final List<String> payoutOrder;
  final bool isAutoAssign;

  final String groupName;
  final String contribution;
  final String frequency;
  final int memberCount;
  final String startDate;

  const FinanceGroupReviewScreen({
    super.key,
    required this.payoutOrder,
    required this.isAutoAssign,
    this.groupName = 'AJO',
    this.contribution = '₦20,000',
    this.frequency = 'Monthly',
    this.memberCount = 3,
    this.startDate = '4/8/2026',
  });

  double get _totalPool {
    final amount =
        double.tryParse(contribution.replaceAll('₦', '').replaceAll(',', '')) ??
        0;
    return amount * memberCount;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review & Confirm',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Step 4 of 4',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Mode toggle (display only)
                  Row(
                    children: ['Auto Assign', 'Manual'].map((mode) {
                      final isActive = isAutoAssign
                          ? mode == 'Auto Assign'
                          : mode == 'Manual';
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: mode == 'Auto Assign' ? 8 : 0,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 44,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.accentOrange
                                  : AppTheme.cardBg(isDark),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                mode,
                                style: GoogleFonts.poppins(
                                  color: isActive
                                      ? Colors.white
                                      : AppTheme.textPrimary(isDark),
                                  fontSize: 14,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Summary card
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
                          groupName,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryItem(
                                icon: Icons.attach_money,
                                label: 'Contribution',
                                value: contribution,
                                isDark: isDark,
                              ),
                            ),
                            Expanded(
                              child: _SummaryItem(
                                icon: Icons.access_time_outlined,
                                label: 'Frequency',
                                value: frequency,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryItem(
                                icon: Icons.group_outlined,
                                label: 'Members',
                                value: '$memberCount',
                                isDark: isDark,
                              ),
                            ),
                            Expanded(
                              child: _SummaryItem(
                                icon: Icons.calendar_month_outlined,
                                label: 'Start Date',
                                value: startDate,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Divider(color: AppTheme.dividerSubtle(isDark)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total pool per cycle',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary(isDark),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '₦${_totalPool.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary(isDark),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payout order card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg(isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payout Order',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...payoutOrder.asMap().entries.map(
                          (e) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBgAlt(isDark),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: e.key == 0
                                        ? AppColors.accentOrange
                                        : AppTheme.cardBg(isDark),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${e.key + 1}',
                                      style: GoogleFonts.poppins(
                                        color: e.key == 0
                                            ? Colors.white
                                            : AppTheme.textPrimary(isDark),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  e.value,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary(isDark),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // What happens next
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.iconBgBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.iconBgBlue, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What happens next?',
                          style: GoogleFonts.poppins(
                            color: AppColors.lightBlueText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...[
                          'Invitations will be sent to all selected members',
                          'Each member must accept the wallet consent agreement',
                          'The group activates when all members have accepted',
                          'First contribution will be deducted on the start date',
                        ].map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.lightBlueText,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    p,
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textSecondary(isDark),
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                CustomButtonTwo(
                  title: 'Confirm & send invites',
                  isLoading: false,
                  hasMargin: false,
                  onClick: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FinanceGroupSuccessScreen(groupName: groupName),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg(isDark),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
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
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.iconColorSubtle(isDark), size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary(isDark), fontSize: 11),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
