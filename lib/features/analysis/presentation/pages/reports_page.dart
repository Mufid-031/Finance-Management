import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/error_utils.dart';
import 'package:finance_management/core/utils/date_formatter.dart';
import 'package:finance_management/features/analysis/presentation/providers/analysis_provider.dart';
import 'package:finance_management/features/analysis/presentation/providers/report_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportNotifierProvider);
    final lastExportLabel = reportState.lastExportDate != null
        ? DateFormatter.getNiceDateLabel(reportState.lastExportDate!)
        : "Never";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports Center",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Export Data",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Download your financial data in various formats for external use.",
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
          const SizedBox(height: 25),

          _ReportActionCard(
            title: "Export to CSV (Excel)",
            description:
                "Detailed list of all transactions, wallets, and categories.",
            icon: Icons.table_chart_rounded,
            color: Colors.green,
            isLoading: reportState.isExporting,
            onTap: () => _showExportOptions(context, ref),
          ),

          const SizedBox(height: 15),

          _ReportActionCard(
            title: "Monthly PDF Summary",
            description:
                "Visual summary of your income and expenses (Coming Soon).",
            icon: Icons.picture_as_pdf_rounded,
            color: Colors.redAccent,
            onTap: () {
              ErrorUtils.showSnackBar(
                context: context,
                message: "Feature coming soon.",
                icon: Icons.auto_awesome,
              );
            },
          ),

          const SizedBox(height: 40),
          const Text(
            "Data Insights",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.widgetColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _InsightRow(
                  label: "Total Transactions",
                  value: reportState.totalTransactions.toString(),
                ),
                const Divider(height: 30),
                _InsightRow(label: "Last Export", value: lastExportLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Export Filter",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Pilih rentang data yang ingin diekspor.",
                style: TextStyle(color: AppColors.grey, fontSize: 14)),
            const SizedBox(height: 25),
            _OptionTile(
              label: "All Transactions",
              icon: Icons.all_inclusive_rounded,
              onTap: () {
                Navigator.pop(context);
                _handleExportCsv(context, ref, filter: 'all');
              },
            ),
            _OptionTile(
              label: "This Month Only",
              icon: Icons.calendar_month_rounded,
              onTap: () {
                Navigator.pop(context);
                _handleExportCsv(context, ref, filter: 'month');
              },
            ),
            _OptionTile(
              label: "Last 3 Months",
              icon: Icons.history_rounded,
              onTap: () {
                Navigator.pop(context);
                _handleExportCsv(context, ref, filter: '3months');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleExportCsv(BuildContext context, WidgetRef ref,
      {required String filter}) async {
    final reportService = ref.read(reportServiceProvider);
    final reportNotifier = ref.read(reportNotifierProvider.notifier);
    
    var transactions = ref.read(transactionsStreamProvider).value ?? [];
    final wallets = ref.read(walletsStreamProvider).value ?? [];
    final categories = ref.read(categoriesStreamProvider).value ?? [];

    if (transactions.isEmpty) {
      ErrorUtils.showError(
          context, "Tidak ada data transaksi untuk diekspor.");
      return;
    }

    // Filter logic
    final now = DateTime.now();
    if (filter == 'month') {
      transactions = transactions
          .where((tx) => tx.date.month == now.month && tx.date.year == now.year)
          .toList();
    } else if (filter == '3months') {
      final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      transactions =
          transactions.where((tx) => tx.date.isAfter(threeMonthsAgo)).toList();
    }

    if (transactions.isEmpty) {
      ErrorUtils.showError(context, "Tidak ada data pada rentang ini.");
      return;
    }

    try {
      reportNotifier.setExporting(true);
      ErrorUtils.showSnackBar(
        context: context,
        message: "Generating report for ${transactions.length} items...",
        icon: Icons.hourglass_empty_rounded,
      );

      await reportService.exportTransactionsToCsv(
        transactions: transactions,
        wallets: wallets,
        categories: categories,
      );

      await reportNotifier.updateLastExportDate();

      if (context.mounted) {
        ErrorUtils.showSuccess(context, "Report generated successfully!");
      }
    } catch (e) {
      if (context.mounted) {
        ErrorUtils.showError(context, "Gagal ekspor: $e");
      }
    } finally {
      reportNotifier.setExporting(false);
    }
  }
}

class _ReportActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ReportActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.widgetColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.main),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label;
  final String value;
  const _InsightRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
