import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../settings/theme/provider/theme_provider.dart';
import '../../../temporary/core_components.dart';

class AddToSavingsScreen extends ConsumerStatefulWidget {
  const AddToSavingsScreen({super.key});

  @override
  ConsumerState<AddToSavingsScreen> createState() => _AddToSavingsScreenState();
}

class _AddToSavingsScreenState extends ConsumerState<AddToSavingsScreen> {
  final TextEditingController _amountController = TextEditingController();
  String enteredAmount = '';

  final double currentBalance = 150000.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String mathFunc(Match match) => '${match[1]},';
    return amount.toStringAsFixed(0).replaceAllMapped(reg, mathFunc);
  }

  @override
  Widget build(BuildContext context) {
    double addedAmount = double.tryParse(enteredAmount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    bool hasAmount = addedAmount > 0;
    double newBalance = currentBalance + addedAmount;
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
            (currentThemeMode == ThemeMode.system &&
                systemBrightness == Brightness.dark);

    final backgroundColor =  isDark
        ? Color(AppColors.primaryBackgroundColor)
        : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            surfaceTintColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Add to savings',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF302B2B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Emergency Fund',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '₦150,000',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '₦350,000 remaining to goal',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Amount to Add',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => setState(() => enteredAmount = val),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: subTextColor),
                          prefixText: '₦  ',
                          prefixStyle: TextStyle(color: subTextColor, fontSize: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Quick Amounts',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        '₦ 1,000',
                        '₦ 2,000',
                        '₦ 5,000',
                        '₦ 10,000',
                        '₦ 20,000',
                        '₦ 50,000',
                        '₦ 70,000',
                        '₦ 100,000',
                      ].map((e) {
                        String numericValue = e.replaceAll(RegExp(r'[^0-9]'), '');
                        bool isSelected = numericValue == enteredAmount.replaceAll(RegExp(r'[^0-9]'), '');

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              enteredAmount = numericValue;
                              _amountController.value = TextEditingValue(
                                text: numericValue,
                                selection: TextSelection.collapsed(offset: numericValue.length),
                              );
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.orange)
                                  : Border.all(color: Colors.transparent),
                            ),
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),

                    if (hasAmount)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Balance',
                              style: TextStyle(color: Colors.green, fontSize: 12),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '₦${_formatCurrency(newBalance)}',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 100),
                    GradientOutlineButton(
                      text: 'Add to savings',
                      onPressed: () {
                        FocusScope.of(context).unfocus(); // Close keyboard before modal
                        if (hasAmount) {
                          showPinConfirmationModal(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter an amount to add.')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
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