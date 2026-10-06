import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';

import '../../../../../utilities/constants/app_colors.dart';

class SavingsCreatedSuccessfullyScreen extends StatelessWidget {
  final VoidCallback? onReturnClick;
  const SavingsCreatedSuccessfullyScreen({super.key, this.onReturnClick});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(AppColors.primaryBackgroundColor),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: -50,
              left: MediaQuery.of(context).size.width / 4,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen.withOpacity(0.12),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            Positioned(
              bottom: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.05),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            SafeArea(
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF102819),
                              border: Border.all(
                                color: AppColors.primaryGreen,
                                width: 3,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                color: AppColors.primaryGreen,
                                size: 50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          const Text(
                            'Money Added!',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'You successfully added money to your savings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 40),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            decoration: BoxDecoration(
                              color: AppColors.amountCardBg,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.amountCardBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: const [
                                Text(
                                  'Amount Added',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '₦100000',
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'to Savings',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryCardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.secondaryCardBorder,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              "Keep up the great work! You're one step closer to achieving your savings goal. 💪",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 40),

                          _buildPrimaryButton(context: context, onClick: onReturnClick ?? () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }),
                          const SizedBox(height: 16),
                          _buildSecondaryButton(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required BuildContext context, required VoidCallback onClick}) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'View All Savings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => CustomBottomNav()), (route) => false);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.secondaryCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryCardBorder, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.home_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Back to Wallet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
