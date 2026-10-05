import 'package:flutter/material.dart';
import 'package:qik_talk/features/wallet/features/e_bills/mobile_data/transaction_status_screen.dart';

import '../../../../../../utilities/constants/app_colors.dart';
import '../../mobile_data/mobile_data_screen.dart';
import '../../utilities/detail_row.dart';
import '../../utilities/enter_pin_bottom_sheet.dart';
import '../../utilities/glass_background.dart';
import 'electricity_status_screen.dart';

class ConfirmDetailsScreen extends StatelessWidget {
  final String meterType;
  final String provider;
  final String meterNumber;
  final String meterName;
  final int amount;

  const ConfirmDetailsScreen({
    super.key,
    required this.meterType,
    required this.provider,
    required this.meterNumber,
    required this.meterName,
    required this.amount,
  });

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
              const Text('Are you sure?', style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Are you sure you want to confirm this payment? This action cannot be undone.',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14, height: 1.4)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBrown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showPinSheet(context);
                    },
                    child: const Text('Proceed', style: TextStyle(fontWeight: FontWeight.w600)),
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
      builder: (context) => EnterPinBottomSheet(onSuccess: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ElectricityStatusScreen(status: TransactionStatus.failed, amount: amount, provider: provider, meterName: meterName, meterNumber: meterNumber)));
      },),
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
        title: const Text('Confirm Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white)),
        centerTitle: false,
      ),
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(radius: 28, backgroundColor: AppColors.buttonBrown, child: Icon(Icons.flash_on, color: AppColors.primaryOrange, size: 30)),
                const SizedBox(height: 16),
                const Text('Amount to Pay', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                const SizedBox(height: 8),
                Text('₦$amount', style: const TextStyle(color: AppColors.textWhite, fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),

                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      DetailRow(title: 'Service Type', value: 'Electricity Payment'),
                      DetailRow(title: 'Provider', value: provider),
                      DetailRow(title: 'Meter Number', value: meterNumber),
                      DetailRow(title: 'Meter Name', value: meterName),
                      DetailRow(title: 'Meter Type', value: meterType, isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

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
                    onPressed: () => _showConfirmationDialog(context),
                    child: const Text('Confirm & Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Edit Details', style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w500)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}