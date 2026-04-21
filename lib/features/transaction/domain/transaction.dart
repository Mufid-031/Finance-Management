import 'package:finance_management/features/category/domain/category.dart';

enum TransactionType { income, expense, transfer }

class Transaction {
  final String id;
  final String userId;
  final String walletId; // Untuk transfer, ini jadi 'Source Wallet'
  final String? toWalletId; // Khusus Transfer: 'Destination Wallet'
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
    this.toWalletId,
    required this.categoryId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
  });
}
