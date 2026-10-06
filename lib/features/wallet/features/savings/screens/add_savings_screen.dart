import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qik_talk/features/wallet/features/savings/screens/savings_created_successfully.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/savings_details_screen.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../e_bills/mobile_data/mobile_data_screen.dart';
import '../../e_bills/utilities/enter_pin_bottom_sheet.dart';

class AddSavingsScreen extends StatefulWidget {
  const AddSavingsScreen({super.key});

  @override
  State<AddSavingsScreen> createState() => _AddSavingsScreenState();
}

class _AddSavingsScreenState extends State<AddSavingsScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedChip;

  final int _currentSavings = 245000;
  final int _targetAmount = 500000;
  final int _remainingTarget = 255000;

  final Map<String, int> _quickAmounts = {
    '₦5K': 5000,
    '₦10K': 10000,
    '₦20K': 20000,
    '₦50K': 50000,
    '₦100K': 100000,
  };

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String formatCurrency(int amount) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amount.toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
  }

  int get _enteredAmount {
    String text = _amountController.text.replaceAll(',', '');
    return int.tryParse(text) ?? 0;
  }

  void _onInputChanged() {
    if (_selectedChip != null && _enteredAmount != _quickAmounts[_selectedChip]) {
      _selectedChip = null;
    }
    setState(() {});
  }

  void _onChipSelected(String chipKey) {
    setState(() {
      _selectedChip = chipKey;
      _amountController.text = formatCurrency(_quickAmounts[chipKey]!);
    });
  }

  void _addAllRemaining() {
    setState(() {
      _selectedChip = null;
      _amountController.text = formatCurrency(_remainingTarget);
    });
  }


  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) =>
          Dialog(
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
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 15),
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
      builder: (context) =>
          EnterPinBottomSheet(
            onSuccess: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      SavingsCreatedSuccessfullyScreen(onReturnClick: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },),
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasInput = _enteredAmount > 0;

    int newBalance = _currentSavings + _enteredAmount;
    int remainingToGoal = _targetAmount - newBalance;
    if (remainingToGoal < 0) remainingToGoal = 0;

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
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                          'Add Money',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Top up your savings',
                          style: TextStyle(
                            color: AppColors.textSubtitle.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.navyCardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.navyCardBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(height: 4),
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
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Current Savings',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '₦${formatCurrency(_currentSavings)}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Remaining',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '₦${formatCurrency(_remainingTarget)}',
                                        style: const TextStyle(
                                          color: AppColors.lightBlueText,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        const Text(
                          'Quick Select Amount',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _quickAmounts.keys.map((chip) {
                            final isSelected = _selectedChip == chip;
                            return GestureDetector(
                              onTap: () => _onChipSelected(chip),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.activeCardBg
                                      : AppColors.darkGreyCard,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.activeCardBorder
                                        : AppColors.darkGreyBorder,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  chip,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),

                        const Text(
                          'Or Enter Custom Amount',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: hasInput
                                ? const Color(0xFF151515)
                                : AppColors.darkGreyCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: hasInput
                                  ? AppColors.textSecondary.withOpacity(0.3)
                                  : AppColors.darkGreyBorder,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '₦',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    TextInputFormatter.withFunction((
                                        oldValue,
                                        newValue,
                                        ) {
                                      if (newValue.text.isEmpty) return newValue;
                                      final int val = int.parse(newValue.text);
                                      final String formatted = formatCurrency(val);
                                      return TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(
                                          offset: formatted.length,
                                        ),
                                      );
                                    }),
                                  ],
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 18,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: _addAllRemaining,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.darkGreyCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.darkGreyBorder,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Add Full Remaining Amount (₦${formatCurrency(_remainingTarget)})',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: hasInput
                              ? Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF261405),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF6B3911),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow(
                                  'Amount to Add:',
                                  '₦${formatCurrency(_enteredAmount)}',
                                ),
                                const SizedBox(height: 16),
                                _buildSummaryRow(
                                  'New Balance:',
                                  '₦${formatCurrency(newBalance)}',
                                ),
                                const SizedBox(height: 16),
                                _buildSummaryRow(
                                  'Remaining to Goal:',
                                  '₦${formatCurrency(remainingToGoal)}',
                                ),
                              ],
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),

                        GestureDetector(
                          onTap: hasInput
                              ? () => _showConfirmationDialog(context)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: hasInput
                                  ? AppColors.buttonActiveBg
                                  : AppColors.buttonInactiveBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Add Money to Savings',
                              style: TextStyle(
                                color: hasInput
                                    ? Colors.white
                                    : AppColors.buttonInactiveText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD4B39A),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.summaryValueText,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}