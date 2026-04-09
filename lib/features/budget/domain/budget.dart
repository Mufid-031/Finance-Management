class Budget {
  final String id;
  final String categoryId;
  final String userId;
  final double limitAmount;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.categoryId,
    required this.userId,
    required this.limitAmount,
    required this.startDate,
    required this.endDate,
  });
}
