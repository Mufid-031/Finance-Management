import 'package:finance_management/features/auth/data/repository/auth_repository.dart';
import 'package:finance_management/features/auth/domain/user.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  Future<User> login(String email, String password) {
    return _repository.login(email, password);
  }

  Future<User> register(String email, String password) {
    return _repository.register(email, password);
  }

  Future<void> logout() {
    return _repository.logout();
  }

  User? getCurrentUser() {
    return _repository.getCurrentUser();
  }
}
