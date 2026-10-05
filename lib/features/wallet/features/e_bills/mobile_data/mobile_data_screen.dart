import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/wallet/features/e_bills/mobile_data/transaction_status_screen.dart';
import 'package:qik_talk/features/wallet/features/e_bills/utilities/enter_pin_bottom_sheet.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:math';

import '../../../../../utilities/constants/app_colors.dart';
import '../utilities/action_btn.dart';
import '../utilities/detail_row.dart';
import '../utilities/glass_background.dart';
import 'data_receipt_screen.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? customBorderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.padding = const EdgeInsets.all(20),
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = customBorderRadius ?? BorderRadius.circular(24);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.buttonBrown.withOpacity(0.4)
                : Colors.white.withOpacity(0.05),
            borderRadius: radius,
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryOrange
                  : Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class MobileDataScreen extends ConsumerStatefulWidget {
  const MobileDataScreen({super.key});

  @override
  ConsumerState<MobileDataScreen> createState() => _MobileDataScreenState();
}

class _MobileDataScreenState extends ConsumerState<MobileDataScreen> {
  String selectedNetwork = 'MTN';
  String phoneNumber = '';
  Map<String, dynamic>? selectedPlan;

  final List<Map<String, dynamic>> dataPlans = [
    {'title': '1GB - Daily Plan', 'price': 300},
    {'title': '2GB - Daily Plan', 'price': 500},
    {'title': '3GB - Daily Plan', 'price': 1000},
    {'title': '5GB - Daily Plan', 'price': 1500},
    {'title': '10GB - Daily Plan', 'price': 2500},
    {'title': '20GB - Daily Plan', 'price': 4000},
  ];

  void _showConfirmationDialog() {
    if (phoneNumber.isEmpty || selectedPlan == null) return;

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
                'Are you sure you want to purchase this data plan? This action cannot be undone.',
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
                      _showPinSheet();
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

  void _showPinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnterPinBottomSheet(onSuccess: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionStatusScreen(status: TransactionStatus.success, amount: 1000, phone: '09131146033',)));
      },),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppTheme.scaffoldBg(isDark),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1,
                    color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                  ),
                ),
                child: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy Data',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                ),
              ),
              Text(
                'Purchase data bundles',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.orangeAccent.withOpacity(0.5) : AppTheme.textSecondary(isDark),
                ),
              ),
            ],
          ),
          centerTitle: false,
          titleSpacing: 0,
        ),
        body: GlassBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Network Provider',
                    style: TextStyle(
                      color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['MTN', 'Airtel', 'Glo', '9Mobile'].map((network) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedNetwork = network),
                            child: GlassCard(
                              isSelected: selectedNetwork == network,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              customBorderRadius: BorderRadius.circular(16),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 1,
                                        color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.12),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.wifi,
                                        color: selectedNetwork == network
                                            ? (isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark))
                                            : AppColors.textGrey,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    network,
                                    style: TextStyle(
                                      color: selectedNetwork == network
                                          ? (isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark))
                                          : AppColors.textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    customBorderRadius: BorderRadius.circular(16),
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark)),
                      onChanged: (val) => setState(() => phoneNumber = val),
                      decoration: InputDecoration(
                        hintText: 'Enter phone number',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textHint(isDark),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,

                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Data Plan',
                        style: TextStyle(
                          color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Daily   Weekly   Monthly',
                        style: TextStyle(
                          color: AppColors.primaryOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: dataPlans.length,
                    itemBuilder: (context, index) {
                      final plan = dataPlans[index];
                      final isSelected = selectedPlan == plan;
                      return GestureDetector(
                        onTap: () => setState(() => selectedPlan = plan),
                        child: GlassCard(
                          isSelected: isSelected,
                          customBorderRadius: BorderRadius.circular(16),
                          padding: EdgeInsets.zero,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                plan['title'],
                                style: TextStyle(
                                  color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₦${plan['price'].toString()}',
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primaryOrange
                                      : (isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark)),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                      onPressed: (phoneNumber.isNotEmpty && selectedPlan != null) ? _showConfirmationDialog : null,
                      child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusScreen extends StatelessWidget {
  final TransactionStatus status;
  final int amount;
  final String phone;

  const StatusScreen({
    Key? key,
    required this.status,
    required this.amount,
    required this.phone,
  }) : super(key: key);

  Color get statusColor {
    switch (status) {
      case TransactionStatus.success:
        return AppColors.successGreen;
      case TransactionStatus.failed:
        return AppColors.errorRed;
      case TransactionStatus.pending:
        return AppColors.pendingOrange;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case TransactionStatus.success:
        return Icons.check_circle_outline;
      case TransactionStatus.failed:
        return Icons.cancel_outlined;
      case TransactionStatus.pending:
        return Icons.access_time;
    }
  }

  String get statusTitle {
    switch (status) {
      case TransactionStatus.success:
        return 'Data Purchase\nSuccessful';
      case TransactionStatus.failed:
        return 'Data Purchase Failed';
      case TransactionStatus.pending:
        return 'Data Purchase\nPending';
    }
  }

  String get statusSubtitle {
    switch (status) {
      case TransactionStatus.success:
        return 'Data has been credited';
      case TransactionStatus.failed:
        return 'insufficient funds. Please top up your wallet.';
      case TransactionStatus.pending:
        return 'Request in progress';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GlassBackground(
        child: SafeArea(
          child: Padding(
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
                    child: Icon(statusIcon, color: statusColor, size: 40),
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
                    color: status == TransactionStatus.failed
                        ? AppColors.textGrey
                        : AppColors.primaryOrange,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '₦$amount',
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
                      DetailRow(title: 'Service Type', value: 'Data Purchase'),
                      DetailRow(title: 'Phone Number', value: phone),
                      DetailRow(
                        title: 'Payment Status',
                        value:
                            status.name[0].toUpperCase() +
                            status.name.substring(1),
                        valueColor: statusColor,
                      ),
                      DetailRow(title: 'Ref Number', value: 'REF876935387'),
                      DetailRow(title: 'Date', value: 'Monday, 30 March 2026'),
                      DetailRow(title: 'Time', value: '14:55:44', isLast: true),
                    ],
                  ),
                ),
                const Spacer(),
                if (status == TransactionStatus.success) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ActionBtn(
                          icon: Icons.share,
                          text: 'Share',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ActionBtn(
                          icon: Icons.download_outlined,
                          text: 'Download',
                          onTap: () {},
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReceiptScreen(),
                        ),
                      ),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
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
          ),
        ),
      ),
    );
  }
}



