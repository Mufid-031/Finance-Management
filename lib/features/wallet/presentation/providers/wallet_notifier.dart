import 'dart:async';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/wallet/application/wallet_service.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _service;
  final Ref _ref;

  WalletNotifier(this._service, this._ref) : super(WalletState());

  Future<void> addWallet(String name, double initialBalance) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = _ref.read(authNotifierProvider).user;

      final newWallet = Wallet(
        id: '',
        name: name,
        balance: initialBalance,
        icon: 'wallet',
      );

      await _service.addWallet(user!.id, newWallet);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> saveWallet({
    String? id,
    required String name,
    required double balance,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final userId = _ref.read(authNotifierProvider).user!.id;
      final wallet = Wallet(
        id: id ?? '',
        name: name,
        balance: balance,
        icon: 'wallet',
      );

      if (id == null) {
        await _service.addWallet(userId, wallet);
      } else {
        await _service.updateWallet(userId, wallet);
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    try {
      state = state.copyWith(isLoading: true);
      final userId = _ref.read(authNotifierProvider).user!.id;
      await _service.updateWallet(userId, wallet);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      state = state.copyWith(isLoading: true);
      final userId = _ref.read(authNotifierProvider).user!.id;
      await _service.deleteWallet(userId, walletId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
