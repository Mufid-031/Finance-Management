import 'dart:async';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/wallet/application/wallet_service.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_state.dart';
import 'package:flutter/material.dart'; // Tambahkan untuk akses Icons default
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _service;
  final Ref _ref;

  WalletNotifier(this._service, this._ref) : super(WalletState());

  // Method Save Tunggal (Bisa Add maupun Update)
  Future<void> saveWallet({
    String? id,
    required String name,
    required double balance,
    int? iconCode, // Tambahkan parameter iconCode
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final userId = _ref.read(authNotifierProvider).user!.id;

      final wallet = Wallet(
        id: id ?? '',
        name: name,
        balance: balance,
        // Gunakan iconCode yang dikirim atau default ke wallet icon
        iconCode: iconCode ?? Icons.account_balance_wallet.codePoint,
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

  // Tetap sediakan update khusus jika hanya ingin passing objek Wallet langsung
  Future<void> updateWallet(Wallet wallet) async {
    try {
      state = state.copyWith(isLoading: true);
      final userId = _ref.read(authNotifierProvider).user!.id;
      await _service.updateWallet(userId, wallet);
      state = state.copyWith(isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      state = state.copyWith(isLoading: true);
      final userId = _ref.read(authNotifierProvider).user!.id;
      await _service.deleteWallet(userId, walletId);
      state = state.copyWith(isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
