import 'package:finance_management/features/settings/data/datasource/settings_firestore_datasource.dart';
import 'package:finance_management/features/settings/data/dto/settings_dto.dart';
import 'package:finance_management/features/settings/data/repository/settings_repository.dart';
import 'package:finance_management/features/settings/domain/settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsFirestoreDatasource datasource;

  SettingsRepositoryImpl(this.datasource);

  @override
  Stream<Settings> watchSettings(String userId) {
    return datasource.watchSettings(userId).map((map) {
      if (map.isEmpty) return Settings.defaultSettings();
      return SettingsDTO.fromMap(map).toDomain();
    });
  }

  @override
  Future<Settings> getSettings(String userId) async {
    final map = await datasource.getSettings(userId);
    if (map.isEmpty) return Settings.defaultSettings();
    return SettingsDTO.fromMap(map).toDomain();
  }

  @override
  Future<void> updateSettings(String userId, Settings settings) {
    final dto = SettingsDTO.fromDomain(settings);
    return datasource.updateSettings(userId, dto.toMap());
  }
}
