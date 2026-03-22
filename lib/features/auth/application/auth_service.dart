import 'package:finance_management/features/auth/data/repository/auth_repository.dart';
import 'package:finance_management/features/auth/domain/user.dart';

class AuthService {
  final AuthRepository repository;

  AuthService(this.repository);

  Future<User> login(String email, String password) {
    return repository.login(email, password);
  }

  Future<User> register(String email, String password) {
    return repository.register(email, password);
  }

  Future<void> logout() {
    return repository.logout();
  }

  User? getCurrentUser() {
    return repository.getCurrentUser();
  }
}
