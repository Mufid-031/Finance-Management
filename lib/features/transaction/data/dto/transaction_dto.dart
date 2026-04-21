import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:finance_management/features/transaction/domain/transaction.dart';

class TransactionDTO {
  final String id;
  final String userId;
  final String walletId;
  final String? toWalletId;
  final String categoryId;
  final String title;
  final double amount;
  final String type; 
  final DateTime date;

  TransactionDTO({
    required this.id,
    required this.userId,
    required this.walletId,
    this.toWalletId,
    required this.categoryId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory TransactionDTO.fromMap(String id, Map<String, dynamic> map) {
    return TransactionDTO(
      id: id,
      userId: map['userId'] ?? '',
      walletId: map['walletId'] ?? '',
      toWalletId: map['toWalletId'],
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'expense',
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  factory TransactionDTO.fromDomain(Transaction tx) {
    return TransactionDTO(
      id: tx.id,
      userId: tx.userId,
      walletId: tx.walletId,
      toWalletId: tx.toWalletId,
      categoryId: tx.categoryId,
      title: tx.title,
      amount: tx.amount,
      type: tx.type.name,
      date: tx.date,
    );
  }

  Transaction toDomain() {
    return Transaction(
      id: id,
      userId: userId,
      walletId: walletId,
      toWalletId: toWalletId,
      categoryId: categoryId,
      title: title,
      amount: amount,
      type: TransactionType.values.firstWhere((e) => e.name == type),
      date: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'walletId': walletId,
      'toWalletId': toWalletId,
      'categoryId': categoryId,
      'title': title,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
