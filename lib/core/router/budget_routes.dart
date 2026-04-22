import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/domain/monthly_summary.dart';
import 'package:finance_management/features/budget/presentation/pages/budget_detail_page.dart';
import 'package:finance_management/features/budget/presentation/pages/budget_page.dart';
import 'package:finance_management/features/budget/presentation/pages/monthly_budget_history_detail_page.dart';
import 'package:go_router/go_router.dart';

final budgetRoutes = [
  GoRoute(path: '/budgets', builder: (context, state) => const BudgetPage()),
  GoRoute(
    path: '/budget-detail',
    name: 'budget-detail',
    builder: (context, state) {
      final budget = state.extra as Budget;
      return BudgetDetailPage(budget: budget);
    },
  ),
  GoRoute(
    path: '/monthly-budget-history-detail',
    name: 'monthly-budget-history-detail',
    builder: (context, state) {
      final summary = state.extra as MonthlySummary;
      return MonthlyBudgetHistoryDetailPage(summary: summary);
    },
  ),
];
