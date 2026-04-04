import 'package:finance_management/features/auth/data/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:finance_management/features/auth/application/auth_service.dart';
import 'package:finance_management/features/auth/data/datasource/firebase_auth_datasource.dart';
import 'package:finance_management/features/auth/data/repository/auth_repository_impl.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_notifier.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_state.dart';

final authDataSourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(authRepositoryProvider));
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref); // Kirim ref ke konstruktor
});
