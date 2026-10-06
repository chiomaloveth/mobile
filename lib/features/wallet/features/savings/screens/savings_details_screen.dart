import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/add_savings_screen.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/withdrawal_screen.dart';

import '../../../../../utilities/constants/app_colors.dart';

String formatCurrency(num amount) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return amount
      .toStringAsFixed(0)
      .replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class SavingsDetailsScreen extends ConsumerWidget {
  const SavingsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: AppTheme.scaffoldBg(isDark),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? Colors.white24 : Colors.black26, width: 1),
                            color: isDark ? const Color(0xFF161616) : AppTheme.cardBg(isDark),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Fund',
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Fixed 6 Months',
                              style: TextStyle(
                                color: isDark ? AppColors.subtitleBrown : AppColors.lightTextSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.navyCardBg : AppTheme.cardBg(isDark),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark ? AppColors.navyCardBorder : AppTheme.border(isDark),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current Savings',
                                            style: TextStyle(
                                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '₦245,000',
                                            style: TextStyle(
                                              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                                              fontSize: 32,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                                        ),
                                        child: Icon(
                                          Icons.visibility_off_outlined,
                                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Progress to Goal', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 13)),
                                      Text('49.0%', style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 8,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.progressTrack : AppTheme.border(isDark),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: 0.49,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          gradient: const LinearGradient(
                                            colors: [AppColors.progressFillBlue, AppColors.progressFillCyan],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Target Amount', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text('₦500,000', style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Days Left', style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text('276 days', style: TextStyle(color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSavingsScreen()));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      decoration: BoxDecoration(
                                        color: AppColors.buttonOrange,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.buttonGlow.withOpacity(0.35),
                                            blurRadius: 25,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            'Add Money',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawalScreen()));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1A1A1A) : AppTheme.cardBg(isDark),
                                        border: Border.all(
                                          color: isDark ? AppColors.darkGreyBorder : AppTheme.border(isDark),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.remove, color: isDark ? Colors.white : AppTheme.textPrimary(isDark), size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Break Vault',
                                            style: TextStyle(
                                              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard('Interest Rate', '10%', AppColors.lightBlueText),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard('Est. Interest', '₦24500', AppColors.successGreen),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard('Remaining', '₦255,000', AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Transaction History',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.file_download_outlined, color: AppColors.accentOrange, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      'Export',
                                      style: TextStyle(
                                        color: AppColors.accentOrange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.85,
                              children: [
                                _buildTransactionCard(
                                  title: 'Initial Deposit',
                                  date: '25 Mar 2026',
                                  amount: '+₦50,000',
                                  isDeposit: true,
                                ),
                                _buildTransactionCard(
                                  title: 'Monthly Savings',
                                  date: '20 Mar 2026',
                                  amount: '+₦25,000',
                                  isDeposit: true,
                                ),
                                _buildTransactionCard(
                                  title: 'Interest Earned',
                                  date: '15 Mar 2026',
                                  amount: '+₦1,200',
                                  isDeposit: false,
                                ),
                                _buildTransactionCard(
                                  title: 'Bonus Savings',
                                  date: '10 Mar 2026',
                                  amount: '+₦30,000',
                                  isDeposit: true,
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor) {
    return Builder(builder: (context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreyCard : AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkGreyBorder : AppTheme.border(isDark), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    });
  }

  Widget _buildTransactionCard({
    required String title,
    required String date,
    required String amount,
    required bool isDeposit,
  }) {
    return Builder(builder: (context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreyCard : AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkGreyBorder : AppTheme.border(isDark), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDeposit
                  ? (isDark ? const Color(0xFF16253D) : const Color(0xFFDDE8F5))
                  : (isDark ? const Color(0xFF0F2C1D) : const Color(0xFFD5F0E3)),
            ),
            child: Icon(
              isDeposit ? Icons.add : Icons.trending_up,
              color: isDeposit ? AppColors.lightBlueText : AppColors.successGreen,
              size: 20,
            ),
          ),

          const Spacer(),

          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: isDeposit ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary) : AppColors.successGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, size: 12),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    }); // Builder
  }
}