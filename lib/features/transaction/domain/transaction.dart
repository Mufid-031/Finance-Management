import 'package:finance_management/features/category/domain/category.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String userId;
  final String walletId;
  final String categoryId;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;

  final Category? category;

  Transaction({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.categoryId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
  });
}
