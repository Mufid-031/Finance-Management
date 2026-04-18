import 'dart:async';

import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/settings/application/settings_service.dart';
import 'package:finance_management/features/settings/domain/settings.dart';
import 'package:flutter/rendering.dart';
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
    _ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.value;

      if (user?.uid != previous?.value?.uid) {
        _subscription?.cancel();
        if (user != null) {
          _startListening(user.uid);
        } else {
          state = Settings.defaultSettings();
        }
      }
    }, fireImmediately: true);
  }

  void _startListening(String userId) {
    _subscription?.cancel();
    _subscription = _service.watchSettings(userId).listen((settings) {
      state = settings;
    });
  }

  Future<void> updateCurrency(String code, String symbol) async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;

    state = state.copyWith(
      currency: code,
      currencySymbol: symbol,
      exchangeRate: Settings.getRate(code),
    );

    try {
      await _service.updateCurrency(user.uid, code, symbol);
    } catch (e) {
      debugPrint("Error updating currency: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
