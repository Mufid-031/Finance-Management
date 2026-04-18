import 'package:finance_management/core/router/analysis_routes.dart';
import 'package:finance_management/core/router/auth_routes.dart';
import 'package:finance_management/core/router/budget_routes.dart';
import 'package:finance_management/core/router/feature_routes.dart';
import 'package:finance_management/core/router/settings_routes.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (authStateAsync.isLoading || authStateAsync.isRefreshing) return null;

      final user = authStateAsync.value;
      final isLoggedIn = user != null;

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
      ...authRoutes,
      ...featureRoutes,
      ...budgetRoutes,
      ...settingsRoutes,
      ...analysisRoutes,
    ],
  );
});
