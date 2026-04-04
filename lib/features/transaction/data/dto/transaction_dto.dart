import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:finance_management/features/transaction/domain/transaction.dart';

class TransactionDTO {
  final String id;
  final String userId;
  final String walletId;
  final String categoryId;
  final String title;
  final double amount;
  final String type; // 'income' atau 'expense'
  final DateTime date;

  TransactionDTO({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.categoryId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  // 1. Dari Firestore Map ke DTO
  factory TransactionDTO.fromMap(String id, Map<String, dynamic> map) {
    return TransactionDTO(
      id: id,
      userId: map['userId'] ?? '',
      walletId: map['walletId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'expense',
      // Firestore menyimpan tanggal sebagai Timestamp, kita ubah ke DateTime
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  // 2. Dari Domain ke DTO (Untuk persiapan simpan)
  factory TransactionDTO.fromDomain(Transaction tx) {
    return TransactionDTO(
      id: tx.id,
      userId: tx.userId,
      walletId: tx.walletId,
      categoryId: tx.categoryId,
      title: tx.title,
      amount: tx.amount,
      type: tx.type == TransactionType.income ? 'income' : 'expense',
      date: tx.date,
    );
  }

  // 3. Dari DTO ke Domain (Untuk dikonsumsi UI)
  Transaction toDomain() {
    return Transaction(
      id: id,
      userId: userId,
      walletId: walletId,
      categoryId: categoryId,
      title: title,
      amount: amount,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      date: date,
    );
  }

  // 4. Dari DTO ke Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'walletId': walletId,
      'categoryId': categoryId,
      'title': title,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date), // Simpan sebagai Timestamp
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
