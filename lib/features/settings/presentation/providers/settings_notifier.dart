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
    final user = _ref.read(authNotifierProvider).user;
    if (user != null) {
      _startListening(user.id);
    }

    _ref.listen(authNotifierProvider, (previous, next) {
      if (next.user?.id != previous?.user?.id) {
        _subscription?.cancel();
        if (next.user != null) _startListening(next.user!.id);
      }
    });
  }

  void _startListening(String userId) {
    _subscription = _service.watchSettings(userId).listen((settings) {
      state = settings;
    });
  }

  Future<void> updateCurrency(String code, String symbol) async {
    final user = _ref.read(authNotifierProvider).user;
    if (user == null) return;

    final newState = state.copyWith(currency: code, currencySymbol: symbol);
    state = newState;

    try {
      await _service.updateCurrency(user.id, code, symbol);
    } catch (e) {
      debugPrint("Error updating currency: $e");
    }
  }
}
