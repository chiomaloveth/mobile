import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/savings_details_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';

import '../../../../../utilities/constants/app_colors.dart';
import 'create_savings_plan_screen.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

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
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const CustomAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            const TotalSavingsCard(),
                            const SizedBox(height: 30),

                            const Text(
                              'Savings Goal',
                              style: TextStyle(
                                color: AppColors.lightTextPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.73,
                              children: const [
                                SavingsPlanCard(
                                  title: 'Emergency Fund',
                                  targetAmount: '₦500,000',
                                  savedAmount: '₦245,000',
                                  progressPercent: 0.49,
                                  durationText: 'Fixed 6 Months',
                                  interestRate: '12% p.a',
                                  iconBgColor: Color(0xFF1C2A3F),
                                  themeColor: Color(0xFF0094FF),
                                ),
                                SavingsPlanCard(
                                  title: 'Vacation Savings',
                                  targetAmount: '₦200,000',
                                  savedAmount: '₦85,000',
                                  progressPercent: 0.43,
                                  durationText: 'Flexible Savings',
                                  interestRate: '8% p.a',
                                  iconBgColor: Color(0xFF351F41),
                                  themeColor: Color(0xFFE42DFF),
                                  isGradient: true,
                                ),
                                SavingsPlanCard(
                                  title: 'Gadget Fund',
                                  targetAmount: '₦150,000',
                                  savedAmount: '₦120,000',
                                  progressPercent: 0.80,
                                  durationText: 'Fixed 3 Months',
                                  interestRate: '10% p.a',
                                  iconBgColor: Color(0xFF163420),
                                  themeColor: AppColors.greenText,
                                ),
                                SavingsPlanCard(
                                  title: 'Gadget Fund',
                                  targetAmount: '₦150,000',
                                  savedAmount: '₦120,000',
                                  progressPercent: 0.80,
                                  durationText: 'Fixed 3 Months',
                                  interestRate: '10% p.a',
                                  iconBgColor: Color(0xFF163420),
                                  themeColor: AppColors.greenText,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
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
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? Colors.white24 : Colors.black26, width: 1),
            color: isDark ? const Color(0xFF1A1A1A) : AppTheme.cardBg(isDark),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Savings',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Manage your savings goals',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary.withOpacity(0.6) : AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF5A2A0A),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateSavingsGoalScreen()));
            },
          ),
        ),
      ],
    );
  }
}

class TotalSavingsCard extends StatelessWidget {
  const TotalSavingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3420),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6B4E31), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF9E5C1B),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Savings',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₦450,000',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSubCard(
                  'This Month',
                  '₦45,000',
                  AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSubCard(
                  'Interest Earned',
                  '₦12,340',
                  AppColors.greenText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubCard(String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SavingsPlanCard extends StatelessWidget {
  final String title;
  final String targetAmount;
  final String savedAmount;
  final double progressPercent;
  final String durationText;
  final String interestRate;
  final Color iconBgColor;
  final Color themeColor;
  final bool isGradient;

  const SavingsPlanCard({
    super.key,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.progressPercent,
    required this.durationText,
    required this.interestRate,
    required this.iconBgColor,
    required this.themeColor,
    this.isGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SavingsDetailsScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white12 : AppTheme.border(isDark), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.savings_outlined, color: themeColor, size: 22),
            ),

            const Spacer(),

            Text(
              title,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              savedAmount,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 6,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF333333) : AppTheme.border(isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * progressPercent,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isGradient ? null : themeColor,
                      gradient: isGradient
                          ? LinearGradient(
                              colors: [themeColor, const Color(0xFFFF267A)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  targetAmount,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${(progressPercent * 100).toInt()}%',
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(height: 1, width: double.infinity, color: isDark ? Colors.white10 : AppTheme.border(isDark)),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  durationText,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  interestRate,
                  style: const TextStyle(
                    color: AppColors.greenText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
