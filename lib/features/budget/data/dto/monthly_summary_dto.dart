import 'package:finance_management/features/budget/domain/monthly_summary.dart';

class MonthlySummaryDTO {
  final String id;
  final int month;
  final int year;
  final double totalLimit;
  final int categoryCount;

  MonthlySummaryDTO({
    required this.id,
    required this.month,
    required this.year,
    required this.totalLimit,
    required this.categoryCount,
  });

  // Tambahkan Factory ini agar Repository bisa mengenali fromMap
  factory MonthlySummaryDTO.fromMap(String id, Map<String, dynamic> map) {
    return MonthlySummaryDTO(
      id: id,
      month: map['month'] ?? 0,
      year: map['year'] ?? 0,
      totalLimit: (map['totalLimit'] ?? 0.0).toDouble(),
      categoryCount: map['categoryCount'] ?? 0,
    );
  }

  // Opsional: Jika Anda butuh konversi balik ke Map
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'totalLimit': totalLimit,
      'categoryCount': categoryCount,
    };
  }

  MonthlySummary toDomain() => MonthlySummary(
    id: id,
    month: month,
    year: year,
    totalLimit: totalLimit,
    categoryCount: categoryCount,
  );
}
