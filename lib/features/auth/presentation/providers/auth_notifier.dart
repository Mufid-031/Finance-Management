import 'package:finance_management/core/errors/failures.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:finance_management/features/auth/application/auth_service.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService service;
  final Ref ref;

  AuthNotifier(this.service, this.ref) : super(AuthState());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: "Email dan password wajib diisi");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await service.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } on FirebaseAuthException catch (e) {
      // Gunakan factory yang kita buat tadi
      final failure = AuthFailure.fromFirebase(e.code);
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Terjadi kesalahan sistem.",
      );
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

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
