class Budget {
  final String id;
  final String categoryId;
  final String monthlySummaryId; // Relasi ke MonthlySummary (userId_yyyy_MM)
  final double limitAmount; // Jatah per kategori
  final double
  spentAmount; // Total yang sudah terpakai (didapat dari transaksi)

  Budget({
    required this.id,
    required this.categoryId,
    required this.monthlySummaryId,
    required this.limitAmount,
    this.spentAmount = 0.0,
  });

  // Getter untuk menghitung sisa budget
  double get remaining => limitAmount - spentAmount;

  // Getter untuk menghitung persentase pemakaian
  double get percentUsed => limitAmount > 0 ? (spentAmount / limitAmount) : 0.0;
}
