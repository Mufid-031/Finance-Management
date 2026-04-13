import 'package:finance_management/features/budget/domain/budget.dart';

class BudgetDTO {
  final String id;
  final String categoryId;
  final String monthlySummaryId;
  final double limitAmount;
  final double spentAmount; // WAJIB ADA agar budget bisa berkurang

  BudgetDTO({
    required this.id,
    required this.categoryId,
    required this.monthlySummaryId,
    required this.limitAmount,
    this.spentAmount = 0.0, // Default 0.0
  });

  // Konversi ke Objek Domain
  Budget toDomain() => Budget(
    id: id,
    categoryId: categoryId,
    monthlySummaryId: monthlySummaryId,
    limitAmount: limitAmount,
    spentAmount: spentAmount,
  );

  factory BudgetDTO.fromMap(String id, Map<String, dynamic> map) => BudgetDTO(
    id: id,
    categoryId: map['categoryId'] ?? '',
    monthlySummaryId: map['monthlySummaryId'] ?? '',
    limitAmount: (map['limitAmount'] as num).toDouble(),
    spentAmount: (map['spentAmount'] as num? ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'monthlySummaryId': monthlySummaryId,
    'limitAmount': limitAmount,
    'spentAmount': spentAmount, // Simpan ke Firestore
  };

  factory BudgetDTO.fromDomain(Budget domain) => BudgetDTO(
    id: domain.id,
    categoryId: domain.categoryId,
    monthlySummaryId: domain.monthlySummaryId,
    limitAmount: domain.limitAmount,
    spentAmount: domain.spentAmount,
  );
}
