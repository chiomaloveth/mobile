import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ═══════════════════════════════════════════════════════════
// USAGE — replace _openSchedulePicker's showDatePicker calls
// with this single call:
//
//   final result = await showCustomSchedulePicker(context);
//   if (result == null || !mounted) return;
//   final confirmed = await _showScheduleConfirmSheet(text, result);
//   if (confirmed != true || !mounted) return;
//   _scheduleMessage(text, result);
//   messageController.clear();
//   setState(() => _isUserTyping = false);
//   _stopTyping();
// ═══════════════════════════════════════════════════════════

Future<DateTime?> showCustomSchedulePicker(BuildContext context) {
  return showModalBottomSheet<DateTime?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SchedulePickerSheet(),
  );
}

class _SchedulePickerSheet extends StatefulWidget {
  const _SchedulePickerSheet();

  @override
  State<_SchedulePickerSheet> createState() => _SchedulePickerSheetState();
}

class _SchedulePickerSheetState extends State<_SchedulePickerSheet> {
  // Step 0 = calendar, Step 1 = time picker
  int _step = 0;

  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;

  // Time
  int _hour = TimeOfDay.now().hour;
  int _minute = TimeOfDay.now().minute;

  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(10, (i) => now + i);
  }

  String get _timeDisplay {
    final h = _hour.toString().padLeft(2, '0');
    final m = _minute.toString().padLeft(2, '0');
    return '$h : $m : 00';
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _onDone() {
    if (_selectedDate == null) return;
    final result = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _hour,
      _minute,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
      child: _step == 0
          ? _CalendarPage(
              key: const ValueKey('calendar'),
              focusedMonth: _focusedMonth,
              selectedDate: _selectedDate,
              months: _months,
              years: _years,
              timeDisplay: _timeDisplay,
              onPrevMonth: _prevMonth,
              onNextMonth: _nextMonth,
              onMonthChanged: (m) => setState(
                () => _focusedMonth = DateTime(_focusedMonth.year, m + 1),
              ),
              onYearChanged: (y) => setState(
                () => _focusedMonth = DateTime(y, _focusedMonth.month),
              ),
              onDateSelected: (d) => setState(() => _selectedDate = d),
              onCancel: () => Navigator.pop(context),
              onNext: _selectedDate != null
                  ? () => setState(() => _step = 1)
                  : null,
            )
          : _TimePage(
              key: const ValueKey('time'),
              hour: _hour,
              minute: _minute,
              selectedDate: _selectedDate!,
              onHourChanged: (h) => setState(() => _hour = h),
              onMinuteChanged: (m) => setState(() => _minute = m),
              onBack: () => setState(() => _step = 0),
              onDone: _onDone,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CALENDAR PAGE
// ─────────────────────────────────────────────────────────────
class _CalendarPage extends StatelessWidget {
  const _CalendarPage({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.months,
    required this.years,
    required this.timeDisplay,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onDateSelected,
    required this.onCancel,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final List<String> months;
  final List<int> years;
  final String timeDisplay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onCancel;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Month / Year row ─────────────────────────────
            Row(
              children: [
                IconButton(
                  onPressed: onPrevMonth,
                  icon: const Icon(Icons.chevron_left, size: 28),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.black87,
                ),
                const SizedBox(width: 4),

                // Month dropdown
                _StyledDropdown<int>(
                  value: focusedMonth.month - 1,
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(value: i, child: Text(months[i])),
                  ),
                  onChanged: (v) => onMonthChanged(v!),
                ),
                const SizedBox(width: 8),

                // Year dropdown
                _StyledDropdown<int>(
                  value: focusedMonth.year,
                  items: years
                      .map(
                        (y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => onYearChanged(v!),
                ),

                const Spacer(),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right, size: 28),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.black87,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Day-of-week header ───────────────────────────
            const _DayHeader(),

            const SizedBox(height: 4),

            // ── Calendar grid ────────────────────────────────
            _CalendarGrid(
              focusedMonth: focusedMonth,
              selectedDate: selectedDate,
              onDateSelected: onDateSelected,
            ),

            const SizedBox(height: 12),

            // ── Bottom bar: time + Cancel / Next ─────────────
            Row(
              children: [
                Text(
                  timeDisplay,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: onNext,
                  child: Text(
                    'Next',
                    style: GoogleFonts.poppins(
                      color: onNext != null
                          ? const Color(0xFF1A7F4B)
                          : Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          isDense: true,
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader();

  static const _days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _days
          .map(
            (d) => SizedBox(
              width: 36,
              child: Center(
                child: Text(
                  d,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    // Previous month filler days
    final prevMonthDays = DateTime(
      focusedMonth.year,
      focusedMonth.month,
      0,
    ).day;

    final List<_DayCell> cells = [];

    // Leading days from previous month
    for (int i = startWeekday - 1; i >= 0; i--) {
      cells.add(
        _DayCell(
          day: prevMonthDays - i,
          isCurrentMonth: false,
          isSelected: false,
          isToday: false,
          isPast: true,
          onTap: null,
        ),
      );
    }

    // Current month days
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, d);
      final isPast = date.isBefore(
        DateTime(today.year, today.month, today.day),
      );
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected =
          selectedDate != null &&
          date.year == selectedDate!.year &&
          date.month == selectedDate!.month &&
          date.day == selectedDate!.day;

      cells.add(
        _DayCell(
          day: d,
          isCurrentMonth: true,
          isSelected: isSelected,
          isToday: isToday,
          isPast: isPast,
          onTap: isPast ? null : () => onDateSelected(date),
        ),
      );
    }

    // Trailing days from next month
    int trailing = 1;
    while (cells.length % 7 != 0) {
      cells.add(
        _DayCell(
          day: trailing++,
          isCurrentMonth: false,
          isSelected: false,
          isToday: false,
          isPast: true,
          onTap: null,
        ),
      );
    }

    final weeks = cells.length ~/ 7;

    return Column(
      children: List.generate(weeks, (w) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (d) {
            return cells[w * 7 + d];
          }),
        );
      }),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.isPast,
    required this.onTap,
  });

  final int day;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final bool isPast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;

    if (isSelected) {
      bgColor = const Color(0xFF1A7F4B);
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = const Color(0xFF1A7F4B).withOpacity(0.15);
      textColor = const Color(0xFF1A7F4B);
    } else if (!isCurrentMonth || isPast) {
      bgColor = Colors.transparent;
      textColor = Colors.black26;
    } else {
      bgColor = Colors.transparent;
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                day.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TIME PICKER PAGE — scroll wheel style
// ─────────────────────────────────────────────────────────────
class _TimePage extends StatefulWidget {
  const _TimePage({
    super.key,
    required this.hour,
    required this.minute,
    required this.selectedDate,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onBack,
    required this.onDone,
  });

  final int hour;
  final int minute;
  final DateTime selectedDate;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  State<_TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<_TimePage> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: widget.hour);
    _minuteController = FixedExtentScrollController(initialItem: widget.minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, d MMM yyyy').format(widget.selectedDate);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Selected date label
            Text(
              dateLabel,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // ── Scroll wheels ─────────────────────────────
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour wheel
                  _TimeWheel(
                    controller: _hourController,
                    itemCount: 24,
                    label: 'HH',
                    onChanged: widget.onHourChanged,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      ':',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Minute wheel
                  _TimeWheel(
                    controller: _minuteController,
                    itemCount: 60,
                    label: 'MM',
                    onChanged: widget.onMinuteChanged,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Bottom buttons ────────────────────────────
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: widget.onBack,
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: widget.onDone,
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1A7F4B),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({
    required this.controller,
    required this.itemCount,
    required this.label,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.black38,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          height: 150,
          child: Stack(
            children: [
              // Selection highlight
              Center(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A7F4B).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 44,
                physics: const FixedExtentScrollPhysics(),
                perspective: 0.003,
                diameterRatio: 2.0,
                onSelectedItemChanged: onChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: itemCount,
                  builder: (context, index) {
                    final isSelected =
                        controller.hasClients &&
                        controller.selectedItem == index;
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: GoogleFonts.poppins(
                          fontSize: isSelected ? 22 : 17,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFF1A7F4B)
                              : Colors.black45,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
