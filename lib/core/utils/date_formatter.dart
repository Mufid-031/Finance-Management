import 'package:intl/intl.dart';

class DateFormatter {
  // Contoh: 15 Oct 2026
  static String dayMonthYear(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Contoh: Mon, 15 Oct
  static String dayWithDayName(DateTime date) {
    return DateFormat('EEE, dd MMM').format(date);
  }

  // Contoh: October 2026 (Cocok untuk Budget Page)
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Untuk pengecekan bulan yang sama (Helper logic)
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  static String getNiceDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) return "Today";
    if (txDate == yesterday) return "Yesterday";
    return DateFormat('dd MMMM yyyy').format(date);
  }
}
