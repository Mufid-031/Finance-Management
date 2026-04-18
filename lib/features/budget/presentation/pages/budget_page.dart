import 'package:finance_management/core/shared/widgets/custom_filter_tabs.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/budget/presentation/widgets/active_budget_view.dart';
import 'package:finance_management/features/budget/presentation/widgets/add_category_budget_modal.dart';
import 'package:finance_management/features/budget/presentation/widgets/budget_history_view.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
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
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    final settings = ref.read(settingsProvider);

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Monthly Limit"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            hintText: "0.00",
            prefixText: "${settings.currencySymbol} ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final settings = ref.read(settingsProvider);

              final amount = double.tryParse(controller.text) ?? 0.0;
              final limit = amount.toBase(settings);
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
      builder: (context) => AddCategoryBudgetModal(),
    );
  }
}
