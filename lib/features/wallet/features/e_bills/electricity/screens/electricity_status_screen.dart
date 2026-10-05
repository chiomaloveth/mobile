import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';

import '../../../../../../utilities/constants/app_colors.dart';
import '../../mobile_data/mobile_data_screen.dart';
import '../../mobile_data/transaction_status_screen.dart';
import '../../utilities/action_btn.dart';
import '../../utilities/detail_row.dart';
import '../../utilities/glass_background.dart';
import '../../utilities/share_title.dart';
import 'electricity_bill_screen.dart';
import 'electricity_receipt_screen.dart';

class ElectricityStatusScreen extends StatefulWidget {
  final TransactionStatus status;
  final int amount;
  final String provider;
  final String meterName;
  final String meterNumber;

  const ElectricityStatusScreen({
    super.key,
    required this.status,
    required this.amount,
    required this.provider,
    required this.meterName,
    required this.meterNumber,
  });

  @override
  State<ElectricityStatusScreen> createState() =>
      _ElectricityStatusScreenState();
}

class _ElectricityStatusScreenState extends State<ElectricityStatusScreen> {
  Color get statusColor => widget.status == TransactionStatus.success
      ? AppColors.successGreen
      : AppColors.errorRed;

  IconData get statusIcon => widget.status == TransactionStatus.success
      ? Icons.check_circle_outline
      : Icons.cancel_outlined;

  String get statusTitle => widget.status == TransactionStatus.success
      ? 'Electricity Payment\nSuccessful!'
      : 'Electricity Payment\nFailed!';

  String get statusSubtitle => widget.status == TransactionStatus.success
      ? 'Token has been sent via sms'
      : 'insufficient funds. Please top up your wallet.';

  String get generatedToken => widget.status == TransactionStatus.success
      ? '1234 5678 9012 3456 7890'
      : '';

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        customBorderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Share Receipt As',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ShareTile(
                icon: Icons.picture_as_pdf,
                title: 'Share as PDF',
                subtitle: 'Portable document format',
                iconColor: Colors.red[300]!,
                bgColor: Colors.red[900]!.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              ShareTile(
                icon: Icons.image,
                title: 'Share as Image',
                subtitle: 'PNG image format',
                iconColor: Colors.blue[300]!,
                bgColor: Colors.blue[900]!.withOpacity(0.3),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color(AppColors.primaryBackgroundColor),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: GlassBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withOpacity(0.1),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor.withOpacity(0.2),
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          statusTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusSubtitle,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '₦${widget.amount}',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              DetailRow(
                                title: 'Provider',
                                value: widget.provider,
                              ),
                              DetailRow(
                                title: 'Meter Number',
                                value: widget.meterNumber,
                              ),
                              DetailRow(
                                title: 'Meter Name',
                                value: widget.meterName,
                              ),
                              DetailRow(
                                title: 'Status',
                                value:
                                    widget.status.name[0].toUpperCase() +
                                    widget.status.name.substring(1),
                                valueColor: statusColor,
                              ),
                              DetailRow(
                                title: 'Payment Mode',
                                value: 'Prepaid',
                              ),
                              DetailRow(
                                title: 'Ref Number',
                                value: 'REF876935387',
                              ),
                              DetailRow(
                                title: 'Date',
                                value: 'Monday, 30 March 2026',
                              ),
                              DetailRow(
                                title: 'Time',
                                value: '14:55:44',
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            if (widget.status == TransactionStatus.success) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ActionBtn(
                                      icon: Icons.share,
                                      text: 'Share',
                                      onTap: () => _showShareSheet(context),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ActionBtn(
                                      icon: Icons.download_outlined,
                                      text: 'Download',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ElectricityReceiptScreen(
                                            amount: widget.amount,
                                            provider: widget.provider,
                                            meterNumber: widget.meterNumber,
                                            token: generatedToken,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.buttonBrown,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: (){
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => CustomBottomNav()), (route) => false);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.home_outlined),
                                      SizedBox(width: 8),
                                      Text(
                                        'Back To Home',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.buttonBrown,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ElectricityBillScreen(),
                                    ),
                                    (route) => false,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.refresh),
                                      SizedBox(width: 8),
                                      Text(
                                        'Try Again',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ActionBtn(
                                      icon: Icons.home_outlined,
                                      text: 'Home',
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ActionBtn(
                                      icon: Icons.chat_bubble_outline,
                                      text: 'Support',
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
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
}
