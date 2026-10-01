import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/finance_group_select_members_screen.dart';

class FinanceGroupSetupScreen extends ConsumerStatefulWidget {
  const FinanceGroupSetupScreen({super.key});

  @override
  ConsumerState<FinanceGroupSetupScreen> createState() =>
      _FinanceGroupSetupScreenState();
}

class _FinanceGroupSetupScreenState extends ConsumerState<FinanceGroupSetupScreen> {
  final _groupNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _membersController = TextEditingController();

  String _frequency = 'Monthly';
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isFormValid =>
      _groupNameController.text.trim().isNotEmpty &&
      _amountController.text.trim().isNotEmpty &&
      _membersController.text.trim().isNotEmpty &&
      int.tryParse(_membersController.text.trim()) != null &&
      int.parse(_membersController.text.trim()) >= 3 &&
      _startDate != null &&
      _endDate != null;

  double get _totalPool {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0;
    final members = int.tryParse(_membersController.text.trim()) ?? 0;
    return amount * members;
  }

  String get _cycleDuration {
    final members = int.tryParse(_membersController.text.trim()) ?? 0;
    if (members == 0) return '';
    final freq = _frequency.toLowerCase();
    return '$members ${freq == 'bi-weekly' ? 'bi-weekly' : freq} periods';
  }

  bool get _showPreview =>
      _amountController.text.isNotEmpty &&
      _membersController.text.isNotEmpty &&
      _startDate != null &&
      _endDate != null;

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => child!,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'mm/dd/yyyy';
    return DateFormat('MM/dd/yyyy').format(date);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _amountController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HexColor('#3A1D07'), HexColor('#171516')],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setup Finance Group',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Step 1 of 4',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Group Name
                  _FieldLabel(text: 'Group Name *', isDark: isDark),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _groupNameController,
                    hint: 'e.g., Monthly Savings Circle',
                    onChanged: (_) => setState(() {}),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Contribution Amount
                  _FieldLabel(text: 'Contribution Amount *', isDark: isDark),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _amountController,
                    hint: '0.00',
                    prefixText: '₦  ',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _AmountFormatter(),
                    ],
                    onChanged: (_) => setState(() {}),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Frequency
                  _FieldLabel(text: 'Contribution Frequency *', isDark: isDark),
                  const SizedBox(height: 10),
                  Row(
                    children: ['Weekly', 'Bi-weekly', 'Monthly']
                        .map(
                          (f) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _frequency = f),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _frequency == f
                                        ? AppColors.accentOrange
                                        : AppTheme.cardBg(isDark),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      f,
                                      style: GoogleFonts.poppins(
                                        color: _frequency == f
                                            ? Colors.white
                                            : AppTheme.textPrimary(isDark),
                                        fontSize: 13,
                                        fontWeight: _frequency == f
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Number of Members
                  _FieldLabel(text: 'Number of Members *', isDark: isDark),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _membersController,
                    hint: 'Min 3 members',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Minimum 3 members required for finance groups',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textHint(isDark),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Start & End Date
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel(text: 'Start Date*', isDark: isDark),
                            const SizedBox(height: 8),
                            _DateField(
                              value: _formatDate(_startDate),
                              onTap: () => _pickDate(isStart: true),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel(text: 'End Date*', isDark: isDark),
                            const SizedBox(height: 8),
                            _DateField(
                              value: _formatDate(_endDate),
                              onTap: () => _pickDate(isStart: false),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Preview card
                  if (_showPreview) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.warningBg : const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.warningBorder : const Color(0xFFFFD699),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total pool per cycle:',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary(isDark),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '₦${NumberFormat('#,###').format(_totalPool)}',
                                style: GoogleFonts.poppins(
                                  color: isDark ? AppColors.warningText : const Color(0xFFD97706),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cycle duration:',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary(isDark),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _cycleDuration,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textPrimary(isDark),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),

          // Bottom button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: Opacity(
              opacity: _isFormValid ? 1.0 : 0.4,
              child: CustomButtonTwo(
                title: 'Continue to Select Members',
                isLoading: false,
                hasMargin: false,
                onClick: _isFormValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FinanceGroupSelectMembersScreen(
                              maxMembers: int.parse(
                                _membersController.text.trim(),
                              ),
                            ),
                          ),
                        );
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please fill all fields correctly.',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            backgroundColor: isDark ? HexColor('#1A1A1A') : const Color(0xFF4A4A4A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable field label
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppTheme.textSecondary(isDark),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// Reusable input field
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final bool isDark;

  const _InputField({
    required this.controller,
    required this.hint,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefixText,
          prefixStyle: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 14),
          hintStyle: GoogleFonts.poppins(color: AppTheme.textHint(isDark), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// Date field
class _DateField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final bool isDark;

  const _DateField({required this.value, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == 'mm/dd/yyyy';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  color: isEmpty ? AppTheme.textHint(isDark) : AppTheme.textPrimary(isDark),
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.calendar_month_outlined,
              color: AppTheme.iconColorSubtle(isDark),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// Amount formatter: adds commas
class _AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) return oldValue;
    final formatted = NumberFormat('#,###').format(number);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
