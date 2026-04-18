import 'package:finance_management/features/auth/presentation/pages/login_page.dart';
import 'package:finance_management/features/auth/presentation/pages/register_page.dart';
import 'package:go_router/go_router.dart';

final authRoutes = [
  GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
];
