import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({Key? key, required this.date}) : super(key: key);

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      // Show weekday name for recent messages
      return _getWeekdayName(messageDate.weekday);
    } else {
      // Show full date for older messages
      return '${messageDate.day}/${messageDate.month}/${messageDate.year}';
    }
  }

  String _getWeekdayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade800.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _getDateLabel(),
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ✅ Helper function to use in ListView.builder
bool shouldShowDateSeparator(List messages, int index) {
  if (index == 0) return true; // Always show for first message

  final currentMsg = messages[index];
  final previousMsg = messages[index - 1];

  final currentDate = DateTime.parse(currentMsg.timestamp);
  final previousDate = DateTime.parse(previousMsg.timestamp);

  // Show separator if day changed
  return currentDate.day != previousDate.day ||
      currentDate.month != previousDate.month ||
      currentDate.year != previousDate.year;
}
