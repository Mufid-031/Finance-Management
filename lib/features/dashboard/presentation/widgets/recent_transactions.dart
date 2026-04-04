import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_filter_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
              const Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildTabTransaction(ref),
              const SizedBox(height: 15),

              // LIST TRANSACTION DENGAN ASYNC DATA
              transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text("Error: $err")),
                data: (transactions) {
                  // FILTER LOGIC: Hanya ambil data 3 hari terakhir (Today, Yesterday, 2 Days Ago)
                  final now = DateTime.now();
                  final threeDaysAgo = DateTime(
                    now.year,
                    now.month,
                    now.day - 2,
                  );

                  var filteredList = transactions.where((tx) {
                    final txDate = DateTime(
                      tx.date.year,
                      tx.date.month,
                      tx.date.day,
                    );

                    // Filter berdasarkan waktu
                    bool isRecent =
                        txDate.isAfter(
                          threeDaysAgo.subtract(const Duration(seconds: 1)),
                        ) ||
                        txDate.isAtSameMomentAs(threeDaysAgo);

                    // Filter berdasarkan Tab (Income/Expense/All)
                    bool matchesTab = true;
                    if (selectedFilter == TransactionFilter.income) {
                      matchesTab = tx.type == TransactionType.income;
                    } else if (selectedFilter == TransactionFilter.spending) {
                      matchesTab = tx.type == TransactionType.expense;
                    }

                    return isRecent && matchesTab;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return _buildEmptyCallback(context);
                  }

                  return _buildRecentTransactionsList(filteredList, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsList(
    List<Transaction> transactions,
    WidgetRef ref,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final dateLabel = _getNiceDateLabel(tx.date);

        // Header Tanggal Dinamis
        bool showHeader = false;
        if (index == 0) {
          showHeader = true;
        } else {
          if (_getNiceDateLabel(tx.date) !=
              _getNiceDateLabel(transactions[index - 1].date)) {
            showHeader = true;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _buildDateSeparator(dateLabel),
            _buildTransactionItem(context, ref, tx),
          ],
        );
      },
    );
  }

  // CALLBACK JIKA KOSONG
  Widget _buildEmptyCallback(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 50,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 10),
            const Text(
              "No transactions in the last 3 days",
              style: TextStyle(color: AppColors.grey),
            ),
            TextButton(
              onPressed: () {}, // Aksi tambah transaksi atau lihat semua
              child: const Text(
                "Add New Transaction",
                style: TextStyle(color: AppColors.main),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPER UNTUK LABEL TANGGAL (Today, Yesterday, dll)
  String _getNiceDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) return "Today";
    if (txDate == yesterday) return "Yesterday";
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WidgetRef ref,
    Transaction tx,
  ) {
    final isExpense = tx.type == TransactionType.expense;

    // AMBIL DATA CATEGORY DARI PROVIDER
    final categories = ref.watch(categoriesStreamProvider).value ?? [];

    // CARI KATEGORI YANG COCOK
    final category = categories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => Category(
        id: '',
        name: 'General',
        icon: Icons.help_outline,
        type: tx.type == TransactionType.expense
            ? CategoryType.expense
            : CategoryType.income,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.backgroundColor,
            // SEKARANG GUNAKAN IKON DARI KATEGORI
            child: Icon(category.icon, color: AppColors.main, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // SEKARANG GUNAKAN NAMA DARI KATEGORI
                Text(
                  category.name,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${isExpense ? '-' : '+'} \$${tx.amount.toStringAsFixed(0)}",
            style: TextStyle(
              color: isExpense ? AppColors.red : AppColors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabTransaction(WidgetRef ref) {
    final selectedFilter = ref.watch(transactionFilterProvider);

    return Row(
      children: TransactionFilter.values.map((filter) {
        final isSelected = selectedFilter == filter;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () =>
                ref.read(transactionFilterProvider.notifier).state = filter,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.main : AppColors.widgetColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.main
                      : AppColors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                filter.name.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.black : AppColors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSeparator(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            date,
            style: const TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: AppColors.white.withOpacity(0.05),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
