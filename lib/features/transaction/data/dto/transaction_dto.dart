import 'package:finance_management/features/transaction/domain/transaction.dart';

class TransactionDTO {
  final String id;
  final String categoryId;

  final double amount;
  final String type;

  final String note;
  final DateTime date;

  TransactionDTO({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
  });

  // FROM FIRESTORE
  factory TransactionDTO.fromMap(String id, Map<String, dynamic> json) {
    return TransactionDTO(
      id: id,
      categoryId: json['categoryId'],
      amount: json['amount'],
      type: json['type'],
      note: json['note'],
      date: json['date'].toDate(),
    );
  }

  // TO DOMAIN
  Transaction toDomain() {
    return Transaction(
      id: id,
      categoryId: categoryId,
      amount: amount,
      type: type,
      note: note,
      date: date,
    );
  }

  // FROM DOMAIN
  factory TransactionDTO.fromDomain(Transaction transaction) {
    return TransactionDTO(
      id: transaction.id,
      categoryId: transaction.categoryId,
      amount: transaction.amount,
      type: transaction.type,
      note: transaction.note,
      date: transaction.date,
    );
  }

  // TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date,
    };
  }
}
