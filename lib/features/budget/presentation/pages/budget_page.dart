import 'package:finance_management/core/shared/widgets/custom_filter_tabs.dart';
import 'package:finance_management/core/theme/app_colors.dart';
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
      appBar: AppBar(
        title: const Text(
          "Monthly Budget",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showSetupBottomSheet(context, ref),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          CustomFilterTabs(
            labels: const ["Current Month", "History"],
            currentIndex: _currentTab,
            onTabChanged: (index) => setState(() => _currentTab = index),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          Expanded(
            child: _currentTab == 0
                ? ActiveBudgetView(
                    onSetupPressed: () => _showSetupBottomSheet(context, ref),
                    onAddCategoryPressed: () =>
                        _showAddCategoryBudget(context, ref),
                  )
                : const BudgetHistoryView(),
          ),
        ],
      ),
    );
  }

  void _showSetupBottomSheet(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final budgetState = ref.read(budgetNotifierProvider);
    final currentLimit =
        (budgetState.activeSummary?.totalLimit ?? 0.0).toConverted(settings);

    final controller =
        TextEditingController(text: currentLimit > 0 ? currentLimit.toString() : "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          left: 25,
          right: 25,
          top: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              "Set Monthly Limit",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Define your overall spending limit for this month.",
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Total Limit",
                hintText: "0.00",
                prefixText: "${settings.currencySymbol} ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  final amount = double.tryParse(controller.text) ?? 0.0;
                  final limit = amount.toBase(settings);
                  if (limit > 0) {
                    ref
                        .read(budgetNotifierProvider.notifier)
                        .setupMonthlyBudget(limit);
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Save Limit",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
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
