import 'package:finance_management/features/auth/presentation/pages/login_page.dart';
import 'package:finance_management/features/auth/presentation/pages/register_page.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/app/presentation/pages/main_page.dart';
import 'package:finance_management/features/budget/presentation/pages/budget_page.dart';
import 'package:finance_management/features/category/presentation/pages/category_page.dart';
import 'package:finance_management/features/wallet/presentation/pages/wallet_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      // final isLoggedIn = authState.user == null; // Login

      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/main';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/main', builder: (context, state) => const MainPage()),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryPage(),
      ),
      GoRoute(
        path: '/wallets',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetPage(),
      ),
    ],
  );
});
