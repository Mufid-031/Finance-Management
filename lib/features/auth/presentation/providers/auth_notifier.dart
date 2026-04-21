import 'package:finance_management/core/errors/failures.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
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

  // --- LOGIN WITH GOOGLE ---
  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await service.loginWithGoogle();
      
      // BOSS, kita jalankan onboarding juga di sini jika datanya kosong
      // (Bisa dicek via repository, tapi untuk sekarang kita pastikan minimal kategori ada)
      await _runOnboarding(user.id);
      
      state = state.copyWith(user: user, isLoading: false);
    } on FirebaseAuthException catch (e) {
      final failure = AuthFailure.fromFirebase(e.code);
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Gagal login dengan Google.",
      );
    }
  }

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
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await service.register(email, password);

      // Jalankan Onboarding Full
      await _runOnboarding(user.id);

      state = state.copyWith(user: user, isLoading: false);
    } on FirebaseAuthException catch (e) {
      final failure = AuthFailure.fromFirebase(e.code);
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Pendaftaran gagal.",
      );
    }
  }

  /// Private helper untuk menjalankan onboarding data awal
  Future<void> _runOnboarding(String userId) async {
    // 1. Buat Wallet Awal
    await ref.read(walletServiceProvider).createInitialWallet(userId);
    
    // 2. Buat Kategori Default
    await ref.read(categoryServiceProvider).seedDefaultCategories(userId);
    
    // BOSS, kita bisa tambahkan onboarding lain kedepannya di sini
  }

  Future<void> logout() async {
    await service.logout();
    state = state.copyWith(user: null, isLoading: false, errorMessage: null);
  }

  void checkAuth() {
    final user = service.getCurrentUser();
    state = state.copyWith(user: user);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
