import 'package:flutter_riverpod/legacy.dart';
import 'package:finance_management/features/auth/application/auth_service.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService service;

  AuthNotifier(this.service) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    final user = await service.login(email, password);

    state = state.copyWith(user: user, isLoading: false);
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true);

    final user = await service.register(email, password);

    state = state.copyWith(user: user, isLoading: false);
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
