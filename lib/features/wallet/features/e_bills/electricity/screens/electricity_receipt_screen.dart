
import 'package:flutter/material.dart';

import '../../../../../../utilities/constants/app_colors.dart';
import '../../mobile_data/mobile_data_screen.dart';
import '../../utilities/detail_row.dart';
import '../../utilities/glass_background.dart';
import '../../utilities/share_title.dart';

class ElectricityReceiptScreen extends StatelessWidget {
  final int amount;
  final String provider;
  final String meterNumber;
  final String token;

  const ElectricityReceiptScreen({super.key, required this.amount, required this.provider, required this.meterNumber, required this.token});

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Electricity Receipt', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white)),
            Text('Transaction details', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 28, backgroundColor: AppColors.buttonBrown, child: Icon(Icons.monetization_on, color: AppColors.primaryOrange, size: 32)),
                      const SizedBox(height: 16),
                      const Text('QikTalk', style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('Transaction Receipt', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12, thickness: 1)),
                      const Text('Amount Paid', style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
                      const SizedBox(height: 8),
                      Text('₦ $amount', style: const TextStyle(color: AppColors.textWhite, fontSize: 36, fontWeight: FontWeight.bold)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12, thickness: 1)),
                      DetailRow(title: 'Status', value: 'Success', valueColor: AppColors.successGreen),
                      DetailRow(title: 'Token', value: token, valueColor: AppColors.primaryOrange, emphasizeValue: true),
                      DetailRow(title: 'Provider', value: provider),
                      DetailRow(title: 'Meter Number', value: meterNumber),
                      DetailRow(title: 'Reference', value: 'REF848001121'),
                      DetailRow(title: 'Date', value: 'Monday, 30 March 2026', isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 25,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonBrown, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => _showShareSheet(context),
                    child: const Text('Share Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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