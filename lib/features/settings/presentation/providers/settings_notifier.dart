import 'dart:async';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/settings/application/settings_service.dart';
import 'package:finance_management/features/settings/domain/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class SettingsNotifier extends StateNotifier<Settings> {
  final SettingsService _service;
  final Ref _ref;
  StreamSubscription? _subscription;

  SettingsNotifier(this._service, this._ref)
    : super(Settings.defaultSettings()) {
    _init();
  }

  void _init() {
    _ref.listen(authNotifierProvider, (previous, next) {
      final user = next.user;
      if (user != null) {
        _subscription?.cancel();
        _subscription = _service.watchSettings(user.id).listen((settings) {
          state = settings;
        });
      }
    }, fireImmediately: true);
  }

  Future<void> updateCurrency(String code, String symbol) async {
    final user = _ref.read(authNotifierProvider).user;
    if (user != null) {
      await _service.updateCurrency(user.id, code, symbol);
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final user = _ref.read(authNotifierProvider).user;
    if (user != null) {
      await _service.toggleTheme(user.id, isDark);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
