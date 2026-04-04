import 'package:finance_management/features/auth/data/datasource/firebase_auth_datasource.dart';
import 'package:finance_management/features/auth/data/repository/auth_repository.dart';
import 'package:finance_management/features/auth/domain/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<User> login(String email, String password) async {
    final result = await _datasource.login(email, password);

    return User(id: result.user!.uid, email: result.user!.email!);
  }

  @override
  Future<User> register(String email, String password) async {
    final result = await _datasource.register(email, password);

    return User(id: result.user!.uid, email: result.user!.email!);
  }

  @override
  Future<void> logout() {
    return _datasource.logout();
  }

  @override
  User? getCurrentUser() {
    final user = _datasource.getCurrentUser();
    if (user == null) return null;

    return User(id: user.uid, email: user.email!);
  }
}
