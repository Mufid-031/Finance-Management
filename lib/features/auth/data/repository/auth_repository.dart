import 'package:finance_management/features/auth/domain/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password);
  Future<void> logout();
  User? getCurrentUser();
}