import 'package:finance_management/features/settings/domain/settings.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension CurrencyFormatting on double {
  // Helper agar bisa panggil: amount.format(ref)
  String format(WidgetRef ref) {
    final symbol = ref.watch(settingsProvider).currencySymbol;
    return "$symbol ${toStringAsFixed(2)}";
  }

  // USD -> IDR, etc
  double toConverted(Settings settings) {
    final rate = settings.exchangeRate ?? 1.0;
    final safeRate = rate == 0 ? 1.0 : rate;
    return this * safeRate;
  }

  // IDR, etc -> USD
  double toBase(Settings settings) {
    final rate = settings.exchangeRate ?? 1.0;
    final safeRate = rate == 0 ? 1.0 : rate;
    return this / safeRate;
  }
}
