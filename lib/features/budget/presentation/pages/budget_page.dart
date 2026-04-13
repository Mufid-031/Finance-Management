import 'package:finance_management/core/shared/widgets/custom_filter_tabs.dart';
import 'package:finance_management/features/budget/presentation/widgets/active_budget_view.dart';
import 'package:finance_management/features/budget/presentation/widgets/add_category_budget_modal.dart';
import 'package:finance_management/features/budget/presentation/widgets/budget_history_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Budget"), centerTitle: true),
      body: Column(
        children: [
          CustomFilterTabs(
            labels: const ["Current Month", "History"],
            currentIndex: _currentTab,
            onTabChanged: (index) => setState(() => _currentTab = index),
          ),
          Expanded(
            child: _currentTab == 0
                ? ActiveBudgetView(
                    onSetupPressed: () => _showSetupDialog(context, ref),
                    onAddCategoryPressed: () =>
                        _showAddCategoryBudget(context, ref),
                  )
                : const BudgetHistoryView(),
          ),
        ],
      ),
    );
  }

  void _showSetupDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Monthly Limit"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "e.g. 500.00",
            prefixText: "\$ ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(controller.text) ?? 0;
              if (limit > 0) {
                ref
                    .read(budgetNotifierProvider.notifier)
                    .setupMonthlyBudget(limit);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryBudget(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryBudgetModal(ref: ref),
    );
  }
}
