import 'package:finance_management/core/shared/widgets/add_transaction_modal.dart';
import 'package:finance_management/core/shared/widgets/custom_chip_filter.dart';
import 'package:finance_management/core/shared/widgets/date_separator.dart';
import 'package:finance_management/core/shared/widgets/empty_state_widget.dart';
import 'package:finance_management/core/shared/widgets/section_header.dart';
import 'package:finance_management/core/shared/widgets/transaction_item_tile.dart';
import 'package:finance_management/core/utils/date_formatter.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final selectedFilter = ref.watch(transactionFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: "Recent Transactions",
                onPressed: () => context.push("/transactions"),
              ),
              const SizedBox(height: 15),

              CustomChipFilter<TransactionFilter>(
                values: TransactionFilter.values,
                selectedValue: selectedFilter,
                labelBuilder: (f) => f.name,
                onSelected: (filter) {
                  ref.read(transactionFilterProvider.notifier).state = filter;
                },
              ),
              const SizedBox(height: 15),
              transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text("Error: $err")),
                data: (transactions) {
                  final now = DateTime.now();
                  final threeDaysAgo = DateTime(
                    now.year,
                    now.month,
                    now.day - 2,
                  );

                  final baseList = transactions.where((tx) {
                    final txDate = DateTime(
                      tx.date.year,
                      tx.date.month,
                      tx.date.day,
                    );
                    bool isRecent = txDate.isAfter(
                      threeDaysAgo.subtract(const Duration(seconds: 1)),
                    );

                    bool matchesTab = true;
                    if (selectedFilter == TransactionFilter.income) {
                      matchesTab = tx.type == TransactionType.income;
                    } else if (selectedFilter == TransactionFilter.spending) {
                      matchesTab = tx.type == TransactionType.expense;
                    } else if (selectedFilter == TransactionFilter.transfer) {
                      matchesTab = tx.type == TransactionType.transfer;
                    }
                    return isRecent && matchesTab;
                  }).toList();

                  final Map<String, int> dailyCount = {};
                  final List<Transaction> filteredList = [];

                  for (var tx in baseList) {
                    final dateKey =
                        "${tx.date.year}-${tx.date.month}-${tx.date.day}";

                    int count = dailyCount[dateKey] ?? 0;

                    if (count < 3) {
                      filteredList.add(tx);
                      dailyCount[dateKey] = count + 1;
                    }
                  }

                  if (filteredList.isEmpty) {
                    return EmptyStateWidget(
                      message: "No transactions in the last 3 days",
                      icon: Icons.receipt_long_outlined,
                      actionLabel: "Add New Transaction",
                      onActionPressed: () => _showAddTransactionModal(context),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final tx = filteredList[index];
                      final categories =
                          ref.watch(categoriesStreamProvider).value ?? [];

                      final category = categories.firstWhere(
                        (c) => c.id == tx.categoryId,
                        orElse: () => Category(
                          id: '',
                          name: tx.type == TransactionType.transfer
                              ? 'Transfer'
                              : 'General',
                          icon: tx.type == TransactionType.transfer
                              ? Icons.swap_horiz
                              : Icons.help_outline,
                          type: CategoryType.expense,
                        ),
                      );

                      final dateLabel = DateFormatter.getNiceDateLabel(tx.date);
                      bool showHeader =
                          index == 0 ||
                          DateFormatter.getNiceDateLabel(tx.date) !=
                              DateFormatter.getNiceDateLabel(
                                filteredList[index - 1].date,
                              );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader) DateSeparator(date: dateLabel),
                          TransactionItemTile(tx: tx, category: category),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const AddTransactionModal(),
    );
  }
}
