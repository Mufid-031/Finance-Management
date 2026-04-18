import 'package:finance_management/features/analysis/presentation/pages/analysis_expenses_page.dart';
import 'package:go_router/go_router.dart';

final analysisRoutes = [
  GoRoute(
    name: 'expenses',
    path: '/analysis/expenses',
    builder: (context, state) => AnalysisExpensesPage(),
  ),
];
