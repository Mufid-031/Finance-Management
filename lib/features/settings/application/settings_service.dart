import 'package:finance_management/features/settings/data/repository/settings_repository.dart';
import 'package:finance_management/features/settings/domain/settings.dart';

class SettingsService {
  final SettingsRepository _repository;

  SettingsService(this._repository);

  Stream<Settings> watchSettings(String userId) {
    return _repository.watchSettings(userId);
  }

  Future<void> updateCurrency(String userId, String code, String symbol) async {
    final current = await _repository.getSettings(userId);
    final updated = current.copyWith(currency: code, currencySymbol: symbol);
    await _repository.updateSettings(userId, updated);
  }

  Future<void> toggleTheme(String userId, bool isDark) async {
    final current = await _repository.getSettings(userId);
    final updated = current.copyWith(isDarkMode: isDark);
    await _repository.updateSettings(userId, updated);
  }
}
