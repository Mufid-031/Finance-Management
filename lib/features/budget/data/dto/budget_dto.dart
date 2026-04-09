import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/budget.dart';

class BudgetDTO {
  final String id;
  final String categoryId;
  final String userId;
  final double limitAmount;
  final DateTime startDate;
  final DateTime endDate;

  BudgetDTO({
    required this.id,
    required this.categoryId,
    required this.userId,
    required this.limitAmount,
    required this.startDate,
    required this.endDate,
  });

  factory BudgetDTO.fromMap(String id, Map<String, dynamic> map) {
    return BudgetDTO(
      id: id,
      categoryId: map['categoryId'] ?? '',
      userId: map['userId'] ?? '',
      limitAmount: (map['limitAmount'] ?? 0.0).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'userId': userId,
      'limitAmount': limitAmount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  Budget toDomain() => Budget(
    id: id,
    categoryId: categoryId,
    userId: userId,
    limitAmount: limitAmount,
    startDate: startDate,
    endDate: endDate,
  );
}
