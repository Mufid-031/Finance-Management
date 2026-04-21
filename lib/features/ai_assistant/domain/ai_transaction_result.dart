import 'package:finance_management/features/transaction/domain/transaction.dart';

class AITransactionResult {
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryId;
  final String? walletId; // Untuk transfer, ini jadi Source Wallet
  final String? toWalletId; // Baru: Untuk Dest Wallet

  AITransactionResult({
    required this.title,
    required this.amount,
    required this.type,
    this.categoryId,
    this.walletId,
    this.toWalletId,
  });

  factory AITransactionResult.fromJson(Map<String, dynamic> json) {
    return AITransactionResult(
      title: json['title'] ?? 'Untitled',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] == 'transfer' 
          ? TransactionType.transfer 
          : (json['type'] == 'income' ? TransactionType.income : TransactionType.expense),
      categoryId: json['categoryId'],
      walletId: json['walletId'],
      toWalletId: json['toWalletId'],
    );
  }
}
