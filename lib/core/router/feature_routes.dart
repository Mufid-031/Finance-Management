import 'package:finance_management/app/presentation/pages/main_page.dart';
import 'package:finance_management/features/category/presentation/pages/category_page.dart';
import 'package:finance_management/features/transaction/presentation/pages/transaction_page.dart';
import 'package:finance_management/features/wallet/presentation/pages/wallet_page.dart';
import 'package:go_router/go_router.dart';

final featureRoutes = [
  GoRoute(path: '/main', builder: (context, state) => const MainPage()),
  GoRoute(
    path: '/categories',
    builder: (context, state) => const CategoryPage(),
  ),
  GoRoute(path: '/wallets', builder: (context, state) => const WalletPage()),
  GoRoute(
    path: '/transactions',
    builder: (context, state) => const TransactionPage(),
  ),
];
