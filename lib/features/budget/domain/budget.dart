class Budget {
  final String id;
  final String userId;
  final String categoryId;

  final double amount;
  final int month;
  final int year;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });
}
