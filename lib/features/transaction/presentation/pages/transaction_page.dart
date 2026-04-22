import 'package:finance_management/core/shared/widgets/add_transaction_modal.dart';
import 'package:finance_management/core/shared/widgets/confirm_dialog.dart';
import 'package:finance_management/core/shared/widgets/custom_filter_tabs.dart';
import 'package:finance_management/core/shared/widgets/date_separator.dart';
import 'package:finance_management/core/shared/widgets/empty_state_widget.dart';
import 'package:finance_management/core/shared/widgets/transaction_item_tile.dart';
import 'package:finance_management/core/utils/date_formatter.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_notifier.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Muat data awal saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionNotifierProvider.notifier).fetchInitialBatch();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(transactionNotifierProvider.notifier).fetchNextBatch();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = ref.watch(filteredTransactionsProvider);
    final txState = ref.watch(transactionNotifierProvider);
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
            labels: const ["ALL", "EXPENSE", "INCOME", "TRANSFER"],
            currentIndex: selectedFilter.index,
            onTabChanged: (index) {
              ref.read(transactionFilterProvider.notifier).state =
                  TransactionFilter.values[index];
            },
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          Expanded(
            child: txState.isLoading && filteredList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                ? EmptyStateWidget(
                    message: searchQuery.isEmpty
                        ? "No transactions yet"
                        : "No results for '$searchQuery'",
                    icon: Icons.search_off_outlined,
                    actionLabel: "Add New Transaction",
                    onActionPressed: () => _showAddTransactionModal(context),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(transactionNotifierProvider.notifier)
                        .refresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                      itemCount:
                          filteredList.length +
                          1, // +1 untuk loading indicator di bawah
                      itemBuilder: (context, index) {
                        if (index == filteredList.length) {
                          // Loading indicator di bagian bawah saat load more
                          return txState.isLoadingMore
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 50);
                        }

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

                        final dateLabel = DateFormatter.getNiceDateLabel(
                          tx.date,
                        );
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
                              Dismissible(
                                key: Key(tx.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => ConfirmDialog(
                                      title: "Delete Transaction",
                                      message:
                                          "Are you sure? Your wallet balance will be restored automatically.",
                                      confirmLabel: "Delete",
                                      onConfirm: () {},
                                    ),
                                  ).then((value) => value ?? false);
                                },
                                onDismissed: (_) {
                                  ref
                                      .read(
                                        transactionNotifierProvider.notifier,
                                      )
                                      .deleteTransaction(tx);
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () => _showAddTransactionModal(
                                    context,
                                    transaction: tx,
                                  ),
                                  child: TransactionItemTile(
                                    tx: tx,
                                    category: category,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
                      },
                    ),
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

  void _showAddTransactionModal(
    BuildContext context, {
    Transaction? transaction,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => AddTransactionModal(transaction: transaction),
    );
  }
}
