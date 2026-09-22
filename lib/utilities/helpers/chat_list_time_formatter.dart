import 'package:intl/intl.dart';

class ChatListTimeFormatter {
  /// Format timestamp for chat list display
  /// Shows: "Today", "Yesterday", Weekday name, or date
  static String formatChatListTime(DateTime dateTime) {
    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(
      localTime.year,
      localTime.month,
      localTime.day,
    );

    // Today - show time
    if (messageDate == today) {
      return DateFormat('h:mm a').format(localTime);
    }

    // Yesterday
    if (messageDate == yesterday) {
      return 'Yesterday';
    }

    // Within last week - show day name
    final daysDiff = now.difference(messageDate).inDays;
    if (daysDiff < 7) {
      return _getWeekdayName(messageDate.weekday);
    }

    // Older than a week - show date
    return DateFormat('dd/MM/yy').format(localTime);
  }

  static String _getWeekdayName(int weekday) {
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

  /// Format for detailed view (e.g., in chat header)
  static String formatDetailedTime(DateTime dateTime) {
    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(
      localTime.year,
      localTime.month,
      localTime.day,
    );

    final timeFormatted = DateFormat('h:mm a').format(localTime);

    if (messageDate == today) {
      return "Today at $timeFormatted";
    }

    if (messageDate == yesterday) {
      return "Yesterday at $timeFormatted";
    }

    final dateFormatted = DateFormat('dd MMM').format(localTime);
    return "$dateFormatted at $timeFormatted";
  }
}
