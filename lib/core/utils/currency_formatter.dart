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

  static String formatLocale({
    required double amount,
    required String symbol,
    required String currencyCode,
  }) {
    // Tentukan locale berdasarkan code
    // IDR -> id_ID (Rp 1.000.000)
    // USD -> en_US ($ 1,000,000)
    final String locale = currencyCode == 'IDR' ? 'id_ID' : 'en_US';

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '$symbol ', // Tambah spasi setelah simbol agar rapi
      decimalDigits: currencyCode == 'IDR'
          ? 0
          : 2, // IDR biasanya tanpa desimal
    );

    return formatter.format(amount);
  }

  static String formatLocaleCompact({
    required double amount,
    required String symbol,
    required String currencyCode,
  }) {
    final String locale = currencyCode == 'IDR' ? 'id_ID' : 'en_US';

    // NumberFormat.compact akan merubah 1.000.000 menjadi 1M atau 1jt
    final formatter = NumberFormat.compactCurrency(
      locale: locale,
      symbol: '$symbol ',
      decimalDigits: 1, // Memberikan satu angka di belakang koma, misal 2.5M
    );

    return formatter.format(amount);
  }
}
