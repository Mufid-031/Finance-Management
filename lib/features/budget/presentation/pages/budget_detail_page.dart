import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_management/core/shared/widgets/date_separator.dart';
import 'package:finance_management/core/shared/widgets/transaction_item_tile.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/core/utils/date_formatter.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
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

          final transactions = ref.watch(transactionsStreamProvider).value ?? [];
          
          // Parse summaryId (YYYY_MM) to get year and month
          final parts = latestBudget.monthlySummaryId.split('_');
          final bYear = int.tryParse(parts[0]) ?? 0;
          final bMonth = int.tryParse(parts[1]) ?? 0;

          final categoryTransactions = transactions.where((tx) =>
              tx.categoryId == latestBudget.categoryId &&
              tx.date.year == bYear &&
              tx.date.month == bMonth).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildProgressHeader(category.name, latestBudget, ref))
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
                const SizedBox(height: 40),
                _buildInfoSection(latestBudget, ref)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 40),
                const Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 15),
                if (categoryTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No transactions in this category for this month.",
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms)
                else
                  ...categoryTransactions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tx = entry.value;
                    final dateLabel = DateFormatter.getNiceDateLabel(tx.date);
                    bool showHeader = index == 0 ||
                        DateFormatter.getNiceDateLabel(tx.date) !=
                            DateFormatter.getNiceDateLabel(
                              categoryTransactions[index - 1].date,
                            );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader) DateSeparator(date: dateLabel),
                        TransactionItemTile(tx: tx, category: category),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (500 + (index * 50)).ms)
                        .slideX(begin: 0.05, end: 0);
                  }),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(
    String categoryName,
    Budget budget,
    WidgetRef ref,
  ) {
    final settings = ref.watch(settingsProvider);

    final convertedLimit = budget.limitAmount.toConverted(settings);
    final convertedSpend = budget.spentAmount.toConverted(settings);

    final percent = convertedLimit > 0 ? (convertedSpend / convertedLimit) : 0.0;

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: percent),
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final isOverBudget = value > 1.0;
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: value > 1.0 ? 1.0 : value,
                    strokeWidth: 15,
                    backgroundColor: AppColors.grey.withValues(alpha: 0.1),
                    color: isOverBudget ? AppColors.red : AppColors.main,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "${(value * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Used", style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 25),
        Text(
          categoryName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Budget budget, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final convertedLimit = budget.limitAmount.toConverted(settings);
    final convertedSpend = budget.spentAmount.toConverted(settings);
    final remainingConverted = budget.remaining.toConverted(settings);

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
            CurrencyFormatter.formatLocale(
              amount: convertedLimit,
              symbol: settings.currencySymbol,
              currencyCode: settings.currency,
            ),
          ),
          const Divider(height: 30),
          _buildDetailRow(
            "Spent So Far",
            CurrencyFormatter.formatLocale(
              amount: convertedSpend,
              symbol: settings.currencySymbol,
              currencyCode: settings.currency,
            ),
            color: AppColors.red,
          ),
          const Divider(height: 30),
          _buildDetailRow(
            "Remaining",
            CurrencyFormatter.formatLocale(
              amount: remainingConverted,
              symbol: settings.currencySymbol,
              currencyCode: settings.currency,
            ),
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
