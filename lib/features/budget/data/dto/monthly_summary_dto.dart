import 'package:finance_management/features/budget/domain/monthly_summary.dart';

class MonthlySummaryDTO {
  final String id;
  final String userId; // Tambahkan ini
  final double totalLimit;
  final int month;
  final int year;
  final int categoryCount;

  MonthlySummaryDTO({
    required this.id,
    required this.userId,
    required this.totalLimit,
    required this.month,
    required this.year,
    required this.categoryCount,
  });

  // Konversi ke Objek Domain (Bukan Map!)
  MonthlySummary toDomain() => MonthlySummary(
    id: id,
    userId: userId,
    totalLimit: totalLimit,
    month: month,
    year: year,
    categoryCount: categoryCount,
  );

  factory MonthlySummaryDTO.fromMap(String id, Map<String, dynamic> map) =>
      MonthlySummaryDTO(
        id: id,
        userId: map['userId'] ?? '',
        totalLimit: (map['totalLimit'] as num).toDouble(),
        month: map['month'] ?? 0,
        year: map['year'] ?? 0,
        categoryCount: map['categoryCount'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'totalLimit': totalLimit,
    'month': month,
    'year': year,
    'categoryCount': categoryCount,
  };

  factory MonthlySummaryDTO.fromDomain(MonthlySummary domain) =>
      MonthlySummaryDTO(
        id: domain.id,
        userId: domain.userId,
        totalLimit: domain.totalLimit,
        month: domain.month,
        year: domain.year,
        categoryCount: domain.categoryCount,
      );
}
