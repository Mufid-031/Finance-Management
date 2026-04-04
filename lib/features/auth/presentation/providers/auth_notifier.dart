import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:finance_management/features/auth/application/auth_service.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService service;
  final Ref ref;

  AuthNotifier(this.service, this.ref) : super(AuthState());

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);

      final user = await service.login(email, password);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, user: null);

      debugPrint("Error Login: $e");
    }
  }

  Future<void> register(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await service.register(email, password);

      // Kita butuh akses ke WalletService di sini
      await ref.read(walletServiceProvider).createInitialWallet(user.id);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    await service.logout();
    state = AuthState(user: null);
  }

  void checkAuth() async {
    final user = service.getCurrentUser();
    state = state.copyWith(user: user);
  }
}
