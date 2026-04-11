class MonthlySummary {
  final String id; // Format: userId_yyyy_MM
  final int month;
  final int year;
  final double totalLimit;
  final int categoryCount;

  MonthlySummary({
    required this.id,
    required this.month,
    required this.year,
    required this.totalLimit,
    required this.categoryCount,
  });
}
