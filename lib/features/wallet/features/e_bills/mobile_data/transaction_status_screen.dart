import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../utilities/action_btn.dart';
import '../utilities/detail_row.dart';
import '../utilities/glass_background.dart';
import '../utilities/share_title.dart';
import 'data_receipt_screen.dart';
import 'mobile_data_screen.dart';

enum TransactionStatus { success, failed, pending }

class TransactionStatusScreen extends StatelessWidget {
  final TransactionStatus status;
  final int amount;
  final String phone;

  const TransactionStatusScreen({super.key, required this.status, required this.amount, required this.phone});

  Color get statusColor {
    switch (status) {
      case TransactionStatus.success: return AppColors.successGreen;
      case TransactionStatus.failed: return AppColors.errorRed;
      case TransactionStatus.pending: return AppColors.pendingOrange;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case TransactionStatus.success: return Icons.check_circle_outline;
      case TransactionStatus.failed: return Icons.cancel_outlined;
      case TransactionStatus.pending: return Icons.access_time;
    }
  }

  String get statusTitle {
    switch (status) {
      case TransactionStatus.success: return 'Data Purchase\nSuccessful';
      case TransactionStatus.failed: return 'Data Purchase Failed';
      case TransactionStatus.pending: return 'Data Purchase\nPending';
    }
  }

  String get statusSubtitle {
    switch (status) {
      case TransactionStatus.success: return 'Data has been credited';
      case TransactionStatus.failed: return 'insufficient funds. Please top up your wallet.';
      case TransactionStatus.pending: return 'Request in progress';
    }
  }

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
        systemNavigationBarColor: Color(AppColors.primaryBackgroundColor),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: GlassBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor.withOpacity(0.1)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor.withOpacity(0.2)),
                        child: Icon(statusIcon, color: statusColor, size: 40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(statusTitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textWhite, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(statusSubtitle, style: TextStyle(color: status == TransactionStatus.failed ? AppColors.textGrey : AppColors.primaryOrange, fontSize: 15)),
                    const SizedBox(height: 20),
                    Text('₦$amount', style: const TextStyle(color: AppColors.textWhite, fontSize: 44, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          DetailRow(title: 'Service Type', value: 'Data Purchase'),
                          DetailRow(title: 'Phone Number', value: phone),
                          DetailRow(title: 'Payment Status', value: status.name[0].toUpperCase() + status.name.substring(1), valueColor: statusColor),
                          DetailRow(title: 'Ref Number', value: 'REF876935387'),
                          DetailRow(title: 'Date', value: 'Monday, 30 March 2026'),
                          DetailRow(title: 'Time', value: '14:55:44', isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                    if (status == TransactionStatus.success) ...[
                      Row(
                        children: [
                          Expanded(child: ActionBtn(icon: Icons.share, text: 'Share', onTap: () => _showShareSheet(context))),
                          const SizedBox(width: 16),
                          Expanded(child: ActionBtn(icon: Icons.download_outlined, text: 'Download', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiptScreen())))),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: (){
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => CustomBottomNav()), (route) => false);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.home_outlined),
                              SizedBox(width: 8),
                              Text('Back To Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.refresh),
                              SizedBox(width: 8),
                              Text('Try Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: ActionBtn(icon: Icons.home_outlined, text: 'Home', onTap: () {})),
                          const SizedBox(width: 16),
                          Expanded(child: ActionBtn(icon: Icons.chat_bubble_outline, text: 'Support', onTap: () {})),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}