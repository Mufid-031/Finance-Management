class Transaction {
  final String id;
  final String categoryId;

  final double amount;
  final String type;

  final String note;
  final DateTime date;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
  });
}