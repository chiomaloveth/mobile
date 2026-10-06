import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/savings_created_successfully.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../e_bills/mobile_data/mobile_data_screen.dart';
import '../../e_bills/utilities/enter_pin_bottom_sheet.dart';


class CreateSavingsGoalScreen extends StatefulWidget {
  const CreateSavingsGoalScreen({super.key});

  @override
  State<CreateSavingsGoalScreen> createState() =>
      _CreateSavingsGoalScreenState();
}

class _CreateSavingsGoalScreenState extends State<CreateSavingsGoalScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _initialDepositController = TextEditingController();

  String? _selectedAmountChip;
  String _selectedPlan = 'Flexible Savings';
  DateTime? _startDate;
  DateTime? _targetDate;

  final Map<String, String> _amountMap = {
    '₦50K': '50000',
    '₦100K': '100000',
    '₦200K': '200000',
    '₦500K': '500000',
    '₦1000K': '1000000',
  };

  @override
  void initState() {
    super.initState();
    _goalNameController.addListener(_updateState);
    _targetAmountController.addListener(_onTargetAmountChanged);
    _initialDepositController.addListener(_updateState);
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _initialDepositController.dispose();
    super.dispose();
  }

  void _updateState() => setState(() {});

  void _onTargetAmountChanged() {
    if (_selectedAmountChip != null &&
        _amountMap[_selectedAmountChip] != _targetAmountController.text) {
      _selectedAmountChip = null;
    }
    setState(() {});
  }

  void _onChipSelected(String chip) {
    setState(() {
      _selectedAmountChip = chip;
      _targetAmountController.text = _amountMap[chip]!;
    });
  }

  bool get _isFormValid {
    return _goalNameController.text
        .trim()
        .isNotEmpty &&
        _targetAmountController.text
            .trim()
            .isNotEmpty &&
        _targetDate != null &&
        _selectedPlan.isNotEmpty;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.month.toString().padLeft(2, '0')}/${date.day
        .toString()
        .padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _targetDate;
    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return CustomDatePickerDialog(
          initialDate: initialDate ?? DateTime.now(),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _targetDate = pickedDate;
        }
      });
    }
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(AppColors.primaryBackgroundColor),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
        body: Stack(
          children: [
            Positioned(
              top: 100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.04),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.04),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    _buildAppBar(),
                    const SizedBox(height: 30),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            _buildSectionTitle('Goal Name'),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _goalNameController,
                              hint: 'e.g., New Car, Vacation',
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Target Amount'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _amountMap.keys.map((amount) {
                                final isSelected = _selectedAmountChip ==
                                    amount;
                                return GestureDetector(
                                  onTap: () => _onChipSelected(amount),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.activeCardBg
                                          : AppColors.cardBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.activeBorderOrange
                                            : AppColors.cardBorder,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      amount,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _targetAmountController,
                              hint: 'Enter target amount',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Text(
                                '₦',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Select Savings Plan'),
                            const SizedBox(height: 12),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.85,
                              children: [
                                _buildPlanCard(
                                  'Flexible Savings',
                                  'Withdraw anytime',
                                  '8%',
                                  isSelected: _selectedPlan ==
                                      'Flexible Savings',
                                ),
                                _buildPlanCard(
                                  'Fixed 3 Months',
                                  'Locked for 3 months',
                                  '10%',
                                  isSelected: _selectedPlan == 'Fixed 3 Months',
                                ),
                                _buildPlanCard(
                                  'Fixed 6 Months',
                                  'Locked for 6 months',
                                  '12%',
                                  isSelected: _selectedPlan == 'Fixed 6 Months',
                                ),
                                _buildPlanCard(
                                  'Fixed 12 Months',
                                  'Locked for 12 months',
                                  '15%',
                                  isSelected: _selectedPlan ==
                                      'Fixed 12 Months',
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      _buildSectionTitle(
                                          'Start Date (Optional)'),
                                      const SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () => _selectDate(isStart: true),
                                        child: CustomTextField(
                                          hint: 'mm/dd/yyyy',
                                          text: _formatDate(_startDate),
                                          isReadOnly: true,
                                          suffixIcon: const Icon(
                                            Icons.calendar_today_outlined,
                                            color: AppColors.textHint,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      _buildSectionTitle('Target Date'),
                                      const SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () =>
                                            _selectDate(isStart: false),
                                        child: CustomTextField(
                                          hint: 'mm/dd/yyyy',
                                          text: _formatDate(_targetDate),
                                          isReadOnly: true,
                                          suffixIcon: const Icon(
                                            Icons.calendar_today_outlined,
                                            color: AppColors.textHint,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Initial Deposit (Optional)'),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _initialDepositController,
                              hint: '0',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Text(
                                '₦',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            GestureDetector(
                              onTap: _isFormValid
                                  ? () => _showConfirmationDialog(context)
                                  : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18),
                                decoration: BoxDecoration(
                                  color: _isFormValid
                                      ? AppColors.buttonActiveBg
                                      : AppColors.buttonInactiveBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Create Savings Goal',
                                  style: TextStyle(
                                    color: _isFormValid
                                        ? AppColors.buttonActiveText
                                        : AppColors.textHint,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
            color: const Color(0xFF161616),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Savings Goal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start saving for your dreams',
              style: TextStyle(
                color: const Color(0xFFC79872).withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPlanCard(String title,
      String subtitle,
      String rate, {
        required bool isSelected,
      }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.activeCardBg : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.activeBorderOrange
                : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: Colors.white12,
                  width: 1,
                ),
              ),
              child: const Text(
                '%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              rate,
              style: const TextStyle(
                color: Color(0xFFD27C38),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'p.a.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final String? text;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isReadOnly;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hint,
    this.text,
    this.prefixIcon,
    this.suffixIcon,
    this.isReadOnly = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.filledInputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
          Expanded(
            child: isReadOnly
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                (text != null && text!.isNotEmpty) ? text! : hint,
                style: TextStyle(
                  color: (text != null && text!.isNotEmpty)
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                  fontSize: 15,
                ),
              ),
            )
                : TextField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
        ],
      ),
    );
  }
}


class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const CustomDatePickerDialog({super.key, required this.initialDate});

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime _currentMonth;
  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final List<int> _years = List.generate(
    20,
        (index) =>
    DateTime
        .now()
        .year + index,
  );

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _changeMonth(int increment) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + increment,
      );
    });
  }

  void _selectDay(int day) {
    Navigator.of(context).pop(
        DateTime(_currentMonth.year, _currentMonth.month, day));
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final int firstWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    ).weekday;
    final int startingOffset = firstWeekday == 7 ? 0 : firstWeekday;

    final int totalCells = 42;

    final int prevMonthDays = DateUtils.getDaysInMonth(
        _currentMonth.year,
        _currentMonth.month - 1
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.calBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                        Icons.chevron_left, color: AppColors.calTextPrimary),
                    onPressed: () => _changeMonth(-1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Row(
                    children: [
                      _buildDropdown(
                        value: _months[_currentMonth.month - 1],
                        items: _months,
                        onChanged: (val) {
                          setState(
                                () =>
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _months.indexOf(val!) + 1,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildDropdown(
                        value: _currentMonth.year.toString(),
                        items: _years.map((e) => e.toString()).toList(),
                        onChanged: (val) {
                          setState(
                                () =>
                            _currentMonth = DateTime(
                              int.parse(val!),
                              _currentMonth.month,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                        Icons.chevron_right, color: AppColors.calTextPrimary),
                    onPressed: () => _changeMonth(1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((day) {
                  return SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: AppColors.calTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 4,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  int displayDay;
                  Color textColor;
                  bool isSelectable = false;

                  if (index < startingOffset) {
                    displayDay = prevMonthDays - (startingOffset - index - 1);
                    textColor = AppColors.calTextLight;
                  } else if (index >= startingOffset + daysInMonth) {
                    displayDay = index - (startingOffset + daysInMonth) + 1;
                    textColor = AppColors.calTextLight;
                  } else {
                    displayDay = index - startingOffset + 1;
                    textColor = AppColors.calTextPrimary;
                    isSelectable = true;
                  }

                  bool isSelected = isSelectable &&
                      widget.initialDate.year == _currentMonth.year &&
                      widget.initialDate.month == _currentMonth.month &&
                      widget.initialDate.day == displayDay;

                  return GestureDetector(
                    onTap: isSelectable ? () => _selectDay(displayDay) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? AppColors.calSelectedCircle : Colors
                            .transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        displayDay.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight
                              .w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.calTextPrimary,
              size: 18,
            ),
          ),
          style: const TextStyle(
            color: AppColors.calTextPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          isDense: true,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}