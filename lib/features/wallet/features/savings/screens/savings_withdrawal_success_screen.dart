import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/savings_details_screen.dart';

import '../../../../../utilities/constants/app_colors.dart';

class WithdrawalSuccessScreen extends StatelessWidget {
  final int amount;

  const WithdrawalSuccessScreen({super.key, required this.amount});

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
              top: 50,
              left: MediaQuery.of(context).size.width / 2 - 100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successGreen.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            SafeArea(
              child: CustomScrollView(
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
                          const SizedBox(height: 60),

                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF063B1D),
                              border: Border.all(
                                color: AppColors.successGreen,
                                width: 3,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                color: AppColors.successGreen,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          const Text(
                            'Withdrawal\nSuccessful!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Your funds have been transferred to your\nmain wallet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 40),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            decoration: BoxDecoration(
                              color: const Color(0xFF05170D),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF133821)),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Withdrawn Amount',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₦${formatCurrency(amount)}',
                                  style: const TextStyle(
                                    color: AppColors.successGreen,
                                    fontSize: 44,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
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
                              color: AppColors.darkGreyCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.darkGreyBorder),
                            ),
                            child: Column(
                              children: [
                                _buildReceiptRow(
                                  'From Savings Goal',
                                  'Emergency Fund',
                                  AppColors.textPrimary,
                                ),
                                const SizedBox(height: 16),
                                _buildReceiptRow(
                                  'Destination',
                                  'Main Wallet',
                                  AppColors.textPrimary,
                                ),
                                const SizedBox(height: 16),
                                _buildReceiptRow(
                                  'Transaction Fee',
                                  '₦0.00',
                                  AppColors.successGreen,
                                ),
                                const SizedBox(height: 16),
                                _buildReceiptRow(
                                  'Date & Time',
                                  '30 Mar 2026, 17:38',
                                  AppColors.textPrimary,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Status',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF063B1D),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Completed',
                                        style: TextStyle(
                                          color: AppColors.successGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 40),

                          GestureDetector(
                            onTap: () => Navigator.popUntil(
                              context,
                                  (route) => route.isFirst,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B3A1A),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Go to Dashboard',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSecondaryButton('View Savings Goal'),
                          const SizedBox(height: 16),
                          _buildSecondaryButton('Back to All Savings'),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.file_download_outlined,
                                color: AppColors.accentOrange,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Download Receipt',
                                style: TextStyle(
                                  color: AppColors.accentOrange,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildReceiptRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryButton(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkGreyBorder),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}