class CategoryReport {
  final String categoryId;
  final String categoryName;
  final double totalAmount;
  final double percentage;
  final int transactionCount;
  final int iconCode;

  CategoryReport({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
    required this.iconCode,
  });
}
