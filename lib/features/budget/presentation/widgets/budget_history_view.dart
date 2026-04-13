import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class BudgetHistoryView extends ConsumerWidget {
  const BudgetHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.history_rounded,
                  color: AppColors.main,
                ),
                title: Text(
                  "${months[s.month]} ${s.year}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${s.categoryCount} Categories"),
                trailing: Text(
                  "\$${s.totalLimit.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
