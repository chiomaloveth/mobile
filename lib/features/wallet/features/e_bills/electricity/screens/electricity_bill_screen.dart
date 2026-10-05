import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/wallet/features/e_bills/utilities/enter_pin_bottom_sheet.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:math';

import '../../../../../../utilities/constants/app_colors.dart';
import '../../mobile_data/mobile_data_screen.dart';
import '../../services/e_bills_services.dart';
import '../../utilities/clickable_glass_card.dart';
import '../../utilities/detail_row.dart';
import '../../utilities/glass_background.dart';
import 'confirm_details_screen.dart';

class ElectricityBillScreen extends ConsumerStatefulWidget {
  const ElectricityBillScreen({super.key});

  @override
  ConsumerState<ElectricityBillScreen> createState() => _ElectricityBillScreenState();
}

class _ElectricityBillScreenState extends ConsumerState<ElectricityBillScreen> {
  final EBillsServices _eBillsServices = EBillsServices();

  String meterType = 'Prepaid';
  String selectedBiller = 'ikeja-electric';
  String meterNumber = '';
  String meterName = '';

  bool _isVerifying = false;
  Timer? _debounce;

  final TextEditingController amountController = TextEditingController();

  final List<Map<String, String>> billers = [
    {'abbr': 'IKEDC', 'value': 'ikeja-electric'},
    {'abbr': 'EKEDC', 'value': 'eko-electric'},
    {'abbr': 'AEDC', 'value': 'abuja-electric'},
    {'abbr': 'IBEDC', 'value': 'ibadan-electric'},
    {'abbr': 'KEDCO', 'value': 'kano-electric'},
    {'abbr': 'KAEDCO', 'value': 'kaduna-electric'},
    {'abbr': 'JEDC', 'value': 'jos-electric'},
    {'abbr': 'PHED', 'value': 'portharcourt-electric'},
    {'abbr': 'EEDC', 'value': 'enugu-electric'},
    {'abbr': 'BEDC', 'value': 'benin-electric'},
  ];

  final List<int> quickAmounts = [1000, 2000, 5000, 10000, 20000, 50000];

  void _onMeterNumberChanged(String val) {
    setState(() {
      meterNumber = val;
      meterName = '';
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (val.length >= 10) {
      _debounce = Timer(const Duration(seconds: 1), () {
        _verifyMeterNumber();
      });
    }
  }

  // --- UPDATED VERIFICATION LOGIC USING THE MODEL ---
  Future<void> _verifyMeterNumber() async {
    setState(() {
      _isVerifying = true;
      meterName = '';
    });

    final verificationResult = await _eBillsServices.verifyElectricityHandler(
      context: context,
      customer_id: meterNumber,
      service_id: selectedBiller,
      variation_id: meterType.toLowerCase(),
    );

    if (verificationResult != null && verificationResult.isSuccess && verificationResult.customerName.isNotEmpty) {
      setState(() {
        meterName = verificationResult.customerName; // Assigned correctly from model
        _isVerifying = false;
      });
    } else {
      setState(() {
        meterName = 'Verification failed or Invalid meter';
        _isVerifying = false;
      });
    }
  }

  void _onQuickAmountSelected(int amount) {
    setState(() {
      amountController.text = amount.toString();
    });
  }

  void _goToConfirmScreen() {
    if (meterNumber.isEmpty || amountController.text.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmDetailsScreen(
          meterType: meterType,
          provider: selectedBiller,
          meterNumber: meterNumber,
          meterName: meterName,
          amount: int.parse(amountController.text),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pay Electricity',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                ),
              ),
              Text(
                'Purchase electricity units',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white.withOpacity(0.7) : AppTheme.textSecondary(isDark),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meter Type',
                    style: TextStyle(
                      color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClickableGlassCard(
                          isSelected: meterType == 'Prepaid',
                          onTap: () {
                            setState(() => meterType = 'Prepaid');
                            if (meterNumber.length >= 10) _verifyMeterNumber();
                          },
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.flash_on,
                                color: meterType == 'Prepaid'
                                    ? (isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark))
                                    : AppColors.textGrey,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Prepaid',
                                style: TextStyle(
                                  color: meterType == 'Prepaid'
                                      ? (isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark))
                                      : AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ClickableGlassCard(
                          isSelected: meterType == 'Postpaid',
                          onTap: () {
                            setState(() => meterType = 'Postpaid');
                            if (meterNumber.length >= 10) _verifyMeterNumber();
                          },
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: meterType == 'Postpaid'
                                    ? (isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark))
                                    : AppColors.textGrey,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Postpaid',
                                style: TextStyle(
                                  color: meterType == 'Postpaid'
                                      ? (isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark))
                                      : AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Biller / Provider',
                    style: TextStyle(
                      color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: billers.length,
                    itemBuilder: (context, index) {
                      final biller = billers[index];
                      final abbr = biller['abbr']!;
                      final actualValue = biller['value']!;

                      return ClickableGlassCard(
                        isSelected: selectedBiller == actualValue,
                        onTap: () {
                          setState(() => selectedBiller = actualValue);
                          if (meterNumber.length >= 10) _verifyMeterNumber();
                        },
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Text(
                            abbr,
                            style: TextStyle(
                              color: selectedBiller == actualValue
                                  ? (isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark))
                                  : AppColors.textGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Meter Number',
                    style: TextStyle(
                      color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClickableGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark)),
                      onChanged: _onMeterNumberChanged,
                      decoration: InputDecoration(
                        hintText: 'Enter meter number',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textHint(isDark),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  if (_isVerifying) ...[
                    const SizedBox(height: 12),
                    Text('Verifying Meter Number...', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    const SizedBox(height: 8),
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange),
                    ),
                  ] else if (meterName.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Meter Name', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                        meterName,
                        style: TextStyle(
                            color: meterName.contains('failed') ? Colors.red : AppColors.primaryOrange,
                            fontSize: 15,
                            fontWeight: FontWeight.w600
                        )
                    ),
                  ],
                  const SizedBox(height: 24),

                  Text(
                    'Quick Select Amount',
                    style: TextStyle(
                      color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: quickAmounts.length,
                    itemBuilder: (context, index) {
                      final amt = quickAmounts[index];
                      return ClickableGlassCard(
                        onTap: () => _onQuickAmountSelected(amt),
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Text(
                            '₦${amt.toString()}',
                            style: TextStyle(
                              color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Or Enter Amount Manually',
                    style: TextStyle(
                      color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClickableGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (v) => setState(() {}),
                      decoration: InputDecoration(
                        prefixText: '₦ ',
                        prefixStyle: TextStyle(
                          color: isDark ? AppColors.textWhite : AppTheme.textPrimary(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textHint(isDark),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                      ),
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
                      onPressed: (meterNumber.isNotEmpty &&
                          amountController.text.isNotEmpty &&
                          !_isVerifying &&
                          !meterName.contains('failed'))
                          ? _goToConfirmScreen : null,
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