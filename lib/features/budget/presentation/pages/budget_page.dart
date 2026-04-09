import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final transactions = ref.watch(transactionsStreamProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Budgets")),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (budgets) {
          if (budgets.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];

              // Cari detail kategori untuk ikon & nama
              final category = categories.firstWhere(
                (c) => c.id == budget.categoryId,
                orElse: () => categories.first.copyWith(name: "Unknown"),
              );

              // Hitung pengeluaran aktual bulan ini untuk kategori ini
              final actualSpending = transactions
                  .where((tx) => tx.categoryId == budget.categoryId)
                  .fold(0.0, (sum, tx) => sum + tx.amount);

              return _buildBudgetCard(
                context,
                budget,
                category,
                actualSpending,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () => _showAddBudgetDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    Budget budget,
    dynamic category,
    double actual,
  ) {
    final progress = (actual / budget.limitAmount).clamp(0.0, 1.0);
    final isOverBudget = actual > budget.limitAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.main.withOpacity(0.1),
                  child: Icon(category.icon, color: AppColors.main),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Limit: \$${budget.limitAmount.toStringAsFixed(0)}",
                        style: const TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  "\$${(budget.limitAmount - actual).toStringAsFixed(0)} left",
                  style: TextStyle(
                    color: isOverBudget ? AppColors.red : AppColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.grey.withOpacity(0.1),
              color: isOverBudget ? AppColors.red : AppColors.main,
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    String? selectedCategoryId;

    // Kita hanya ingin membatasi pengeluaran (Expense)
    final categories =
        ref
            .read(categoriesStreamProvider)
            .value
            ?.where((c) => c.type == CategoryType.expense)
            .toList() ??
        [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Set Category Budget",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Pilih Kategori
              const Text(
                "Select Category",
                style: TextStyle(color: AppColors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: categories
                    .map(
                      (c) => ChoiceChip(
                        avatar: Icon(
                          c.icon,
                          size: 16,
                          color: selectedCategoryId == c.id
                              ? Colors.black
                              : AppColors.main,
                        ),
                        label: Text(c.name),
                        selected: selectedCategoryId == c.id,
                        onSelected: (val) =>
                            setModalState(() => selectedCategoryId = c.id),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Input Limit
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Monthly Limit Amount",
                  prefixText: "\$ ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedCategoryId != null &&
                        amountController.text.isNotEmpty) {
                      await ref
                          .read(budgetNotifierProvider.notifier)
                          .saveBudget(
                            categoryId: selectedCategoryId!,
                            limit: double.parse(amountController.text),
                          );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Save Budget",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "No budgets set yet",
            style: TextStyle(color: AppColors.grey),
          ),
          TextButton(
            onPressed: () => _showAddBudgetDialog(context, ref),
            child: const Text("Create your first budget"),
          ),
        ],
      ),
    );
  }
}
