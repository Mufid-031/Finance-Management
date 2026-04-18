import 'package:finance_management/core/shared/widgets/add_transaction_modal.dart';
import 'package:finance_management/core/shared/widgets/custom_filter_tabs.dart';
import 'package:finance_management/core/shared/widgets/date_separator.dart';
import 'package:finance_management/core/shared/widgets/empty_state_widget.dart';
import 'package:finance_management/core/shared/widgets/transaction_item_tile.dart';
import 'package:finance_management/core/utils/date_formatter.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredList = ref.watch(filteredTransactionsProvider);

    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final selectedFilter = ref.watch(transactionFilterProvider);
    final searchQuery = ref.watch(transactionSearchProvider).toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions History"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // INPUT SEARCH
                TextField(
                  onChanged: (val) =>
                      ref.read(transactionSearchProvider.notifier).state = val,
                  decoration: InputDecoration(
                    hintText: "Search transactions...",
                    prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                    filled: true,
                    fillColor: AppColors.widgetColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          CustomFilterTabs(
            labels: const ["ALL", "EXPENSE", "INCOME"],
            currentIndex: selectedFilter.index,
            onTabChanged: (index) {
              ref.read(transactionFilterProvider.notifier).state =
                  TransactionFilter.values[index];
            },
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (transactions) {
                if (filteredList.isEmpty) {
                  return EmptyStateWidget(
                    message: searchQuery.isEmpty
                        ? "No transactions yet"
                        : "No results for '$searchQuery'",
                    icon: Icons.search_off_outlined,
                    actionLabel: "Add New Transaction",
                    onActionPressed: () => _showAddTransactionModal(context),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 80),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final tx = filteredList[index];
                    final categories =
                        ref.watch(categoriesStreamProvider).value ?? [];

                    final category = categories.firstWhere(
                      (c) => c.id == tx.categoryId,
                      orElse: () => Category(
                        id: '',
                        name: 'General',
                        icon: Icons.help_outline,
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

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader) DateSeparator(date: dateLabel),
                          TransactionItemTile(tx: tx, category: category),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () => _showAddTransactionModal(context),
        child: const Icon(Icons.add, color: Colors.black),
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
