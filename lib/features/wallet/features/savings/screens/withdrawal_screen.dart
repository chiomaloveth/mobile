import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../utilities/constants/app_colors.dart';
import 'confirm_withdrawal_screen.dart';

// Note: Ensure these point to your actual project paths
// import '../../../../../utilities/constants/app_colors.dart';
// import 'confirm_withdrawal_screen.dart';
// -----------------------------------------------

String formatCurrency(num amount) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return amount
      .toStringAsFixed(0)
      .replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedChip;

  final int _availableBalance = 275000;

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

  int get _enteredAmount {
    String text = _amountController.text.replaceAll(',', '');
    return int.tryParse(text) ?? 0;
  }

  void _onInputChanged() {
    int currentInput = _enteredAmount;

    String? matchedChip;
    _quickAmounts.forEach((key, value) {
      if (value == currentInput) matchedChip = key;
    });

    if (_selectedChip != matchedChip) {
      _selectedChip = matchedChip;
    }
    setState(() {});
  }

  void _onChipSelected(String chipKey) {
    setState(() {
      _selectedChip = chipKey;
      _amountController.text = formatCurrency(_quickAmounts[chipKey]!);
    });
  }

  void _withdrawAll() {
    setState(() {
      _selectedChip = null;
      _amountController.text = formatCurrency(_availableBalance);
    });
  }

  void _continueToConfirm() {
    if (_enteredAmount > 0 && _enteredAmount <= _availableBalance) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmWithdrawalScreen(
            amount: _enteredAmount,
            currentBalance: _availableBalance,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasInput = _enteredAmount > 0;
    bool isValid = _enteredAmount > 0 && _enteredAmount <= _availableBalance;
    int remainingBalance = _availableBalance - _enteredAmount;

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
                          'Withdraw',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Take money from savings',
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
                            border: Border.all(color: AppColors.navyCardBorder),
                          ),
                          child: Column(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Emergency Fund',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Available Balance',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '₦${formatCurrency(_availableBalance)}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Interest Rate',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        '10%',
                                        style: TextStyle(
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
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.warningBorder,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFEAB308),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Early Withdrawal Notice',
                                      style: TextStyle(
                                        color: Color(0xFFEAB308),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Withdrawing before maturity may affect your interest earnings. Consider keeping your funds invested to maximize returns.',
                                      style: TextStyle(
                                        color: AppColors.warningText,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
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
                                      if (newValue.text.isEmpty)
                                        return newValue;
                                      final int val = int.parse(newValue.text);
                                      final String formatted = formatCurrency(
                                        val,
                                      );
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
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: _withdrawAll,
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
                              'Withdraw All (₦${formatCurrency(_availableBalance)})',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

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
                                      color: const Color(
                                        0xFF6B3911,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Withdrawal Amount:',
                                            style: TextStyle(
                                              color: Color(0xFFD4B39A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '₦${formatCurrency(_enteredAmount)}',
                                            style: const TextStyle(
                                              color: AppColors.summaryValueText,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Remaining Balance:',
                                            style: TextStyle(
                                              color: Color(0xFFD4B39A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '₦${formatCurrency(remainingBalance < 0 ? 0 : remainingBalance)}',
                                            style: const TextStyle(
                                              color: AppColors.summaryValueText,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        GestureDetector(
                          onTap: isValid ? _continueToConfirm : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: isValid
                                  ? AppColors.buttonActiveBg
                                  : AppColors.buttonInactiveBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Continue to Withdraw',
                              style: TextStyle(
                                color: isValid
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
}
