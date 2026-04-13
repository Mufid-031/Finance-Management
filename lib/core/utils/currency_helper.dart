import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension CurrencyFormatting on double {
  // Helper agar bisa panggil: amount.format(ref)
  String format(WidgetRef ref) {
    final symbol = ref.watch(settingsProvider).currencySymbol;
    return "$symbol ${toStringAsFixed(2)}";
  }
}
