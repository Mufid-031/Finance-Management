import 'package:finance_management/features/settings/domain/settings.dart';

abstract class SettingsRepository {
  Stream<Settings> watchSettings(String userId);
  Future<Settings> getSettings(String userId);
  Future<void> updateSettings(String userId, Settings settings);
}
