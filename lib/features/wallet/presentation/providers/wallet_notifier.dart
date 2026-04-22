import 'dart:async';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/wallet/application/wallet_service.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _service;
  final Ref _ref;

  WalletNotifier(this._service, this._ref) : super(WalletState());

  Future<void> saveWallet({
    String? id,
    required String name,
    required double balance,
    int? iconCode, // Tambahkan parameter iconCode
    required String currency,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      final wallet = Wallet(
        id: id ?? '',
        name: name,
        balance: balance,
        iconCode: iconCode ?? Icons.account_balance_wallet.codePoint,
        currency: currency,
      );

      if (id == null) {
        await _service.addWallet(userId, wallet);
      } else {
        await _service.updateWallet(userId, wallet);
      }

      state = state.copyWith(isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await _service.updateWallet(userId, wallet);
      state = state.copyWith(isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      final userId = _ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await _service.deleteWallet(userId, walletId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
