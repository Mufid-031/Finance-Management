import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/core/shared/widgets/confirm_dialog.dart';

class BudgetDetailPage extends ConsumerWidget {
  final Budget budget;

  const BudgetDetailPage({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    // SOLUSI: Ambil data budget terbaru dari provider berdasarkan ID
    final budgetState = ref.watch(budgetNotifierProvider);
    final latestBudget = budgetState.categoryBudgets.firstWhere(
      (b) => b.id == budget.id,
      orElse: () => budget, // Fallback ke data awal jika tidak ditemukan
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.red),
            onPressed: () => _showDeleteConfirm(context, ref),
          ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (categories) {
          final category = categories.firstWhere(
            (c) => c.id == latestBudget.categoryId,
            orElse: () => categories.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                // Gunakan latestBudget, bukan budget
                _buildProgressHeader(category.name, latestBudget),
                const SizedBox(height: 40),
                _buildInfoSection(latestBudget),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(String categoryName, Budget budget) {
    final percent = budget.limitAmount > 0
        ? (budget.spentAmount / budget.limitAmount)
        : 0.0;
    final isOverBudget = budget.spentAmount > budget.limitAmount;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: percent > 1.0 ? 1.0 : percent,
                strokeWidth: 15,
                backgroundColor: AppColors.grey.withValues(alpha: 0.1),
                color: isOverBudget ? AppColors.red : AppColors.main,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              children: [
                Text(
                  "${(percent * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Used", style: TextStyle(color: AppColors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 25),
        Text(
          categoryName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Budget budget) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            "Monthly Limit",
            "\$${budget.limitAmount.toStringAsFixed(2)}",
          ),
          const Divider(height: 30),
          _buildDetailRow(
            "Spent So Far",
            "\$${budget.spentAmount.toStringAsFixed(2)}",
            color: AppColors.red,
          ),
          const Divider(height: 30),
          _buildDetailRow(
            "Remaining",
            "\$${budget.remaining.toStringAsFixed(2)}",
            color: budget.remaining < 0 ? AppColors.red : AppColors.main,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.grey, fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    ConfirmDialog.show(
      context,
      title: "Remove Budget",
      message:
          "Are you sure you want to remove this category from your monthly budget?",
      onConfirm: () async {
        await ref
            .read(budgetNotifierProvider.notifier)
            .removeCategoryBudget(budget.monthlySummaryId, budget.id);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}
