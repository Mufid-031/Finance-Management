import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Format ke USD (atau sesuaikan dengan kebutuhan Anda)
  // Contoh: 10000 -> $10,000
  static String format(double amount) {
    return NumberFormat.currency(
      symbol: '\$ ',
      decimalDigits: 0, // Ubah ke 2 jika ingin ada sen (.00)
    ).format(amount);
  }

  // Versi ringkas untuk angka besar (K, M, B)
  // Contoh: 1500 -> 1.5K
  static String formatCompact(double amount) {
    return NumberFormat.compactCurrency(
      symbol: '\$ ',
      decimalDigits: 1,
    ).format(amount);
  }
}
