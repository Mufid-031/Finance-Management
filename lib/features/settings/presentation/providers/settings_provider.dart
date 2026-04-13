import 'package:finance_management/features/settings/application/settings_service.dart';
import 'package:finance_management/features/settings/data/datasource/settings_firestore_datasource.dart';
import 'package:finance_management/features/settings/data/repository/settings_repository_impl.dart';
import 'package:finance_management/features/settings/domain/settings.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final settingsDatasourceProvider = Provider(
  (ref) => SettingsFirestoreDatasource(),
);

final settingsRepositoryProvider = Provider((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsDatasourceProvider));
});

final settingsServiceProvider = Provider((ref) {
  return SettingsService(ref.watch(settingsRepositoryProvider));
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((
  ref,
) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsNotifier(service, ref);
});
