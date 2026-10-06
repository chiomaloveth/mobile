import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/savings_details_screen.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/savings_withdrawal_success_screen.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/withdrawal_screen.dart' hide formatCurrency;
import '../../../../../utilities/constants/app_colors.dart';
import '../../e_bills/mobile_data/mobile_data_screen.dart';
import '../../e_bills/utilities/enter_pin_bottom_sheet.dart';

String formatCurrency(num amount) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return amount
      .toStringAsFixed(0)
      .replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class ConfirmWithdrawalScreen extends StatefulWidget {
  final int amount;
  final int currentBalance;

  const ConfirmWithdrawalScreen({
    super.key,
    required this.amount,
    required this.currentBalance,
  });

  @override
  State<ConfirmWithdrawalScreen> createState() => _ConfirmWithdrawalScreenState();
}

class _ConfirmWithdrawalScreenState extends State<ConfirmWithdrawalScreen> {
  final int _breakFee = 5000;
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure?',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to confirm this payment? This action cannot be undone.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBrown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showPinSheet(context);
                    },
                    child: const Text(
                      'Proceed',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnterPinBottomSheet(
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WithdrawalSuccessScreen(amount: widget.amount),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int newBalance = widget.currentBalance - widget.amount - _breakFee;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1),
                        color: const Color(0xFF161616),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Confirm Withdrawal',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Review withdrawal details',
                          style: TextStyle(
                            color: AppColors.textSubtitle.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Withdrawal Amount',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₦${formatCurrency(widget.amount)}',
                          style: const TextStyle(
                            color: AppColors.amountLargeText,
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkGreyCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.darkGreyBorder),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.iconBgBlue,
                                      ),
                                      child: const Icon(
                                        Icons.savings_outlined,
                                        color: AppColors.iconBlue,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Emergency Fund',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Fixed 6 Months',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(color: AppColors.darkGreyBorder, height: 1),

                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _buildDetailRow(
                                      'Current Balance',
                                      '₦${formatCurrency(widget.currentBalance)}',
                                      AppColors.textPrimary,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDetailRow(
                                      'Withdrawal Amount',
                                      '-₦${formatCurrency(widget.amount)}',
                                      AppColors.textRed,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDetailRow(
                                      'Break Fee:',
                                      '-₦${formatCurrency(_breakFee)}',
                                      AppColors.textRed,
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(color: AppColors.darkGreyBorder, height: 1),

                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: AppColors.cardBottomBg,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: _buildDetailRow(
                                  'New Balance',
                                  '₦${formatCurrency(newBalance)}',
                                  AppColors.textPrimary,
                                  isBold: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Transaction Details',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.darkGreyCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.darkGreyBorder),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Destination',
                                'Main Wallet',
                                AppColors.textPrimary,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                'Processing Fee',
                                '₦0.00',
                                AppColors.successGreen,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                'Processing Time',
                                'Instant',
                                AppColors.textPrimary,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                'Date & Time',
                                '30 Mar 2026',
                                AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.infoGreenBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.infoGreenBorder),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.successGreen,
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Funds will be instantly transferred to your main wallet and available for use immediately.',
                                  style: TextStyle(
                                    color: AppColors.successGreen,
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        GestureDetector(
                          onTap: () => _showConfirmationDialog(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: AppColors.buttonActiveBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Confirm Withdrawal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: AppColors.buttonCancelBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.darkGreyBorder),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
      ),
    );
  }

  Widget _buildDetailRow(
      String label,
      String value,
      Color valueColor, {
        bool isBold = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}