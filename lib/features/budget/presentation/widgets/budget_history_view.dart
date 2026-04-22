import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/core/theme/app_colors.dart';

import 'package:go_router/go_router.dart';

class BudgetHistoryView extends ConsumerWidget {
  const BudgetHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final historyAsync = ref.watch(monthlySummariesStreamProvider);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (summaries) {
        if (summaries.isEmpty) {
          return const Center(child: Text("No budget history found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: summaries.length,
          itemBuilder: (context, index) {
            final s = summaries[index];
            final months = [
              "",
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun",
              "Jul",
              "Aug",
              "Sep",
              "Oct",
              "Nov",
              "Dec",
            ];

            final convertedTotalLimit = s.totalLimit.toConverted(settings);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.widgetColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ListTile(
                onTap: () => context.pushNamed('monthly-budget-history-detail', extra: s),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.main.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.main,
                    size: 24,
                  ),
                ),
                title: Text(
                  "${months[s.month]} ${s.year}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${s.categoryCount} Categories"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.formatLocaleCompact(
                        amount: convertedTotalLimit,
                        symbol: settings.currencySymbol,
                        currencyCode: settings.currency,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
