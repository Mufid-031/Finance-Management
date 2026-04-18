import 'package:finance_management/core/utils/color_generator.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/budget/domain/budget.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class CategoryBudgetItem extends ConsumerWidget {
  final Budget budget;
  const CategoryBudgetItem({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    final categoryColor = ColorGenerator.fromId(budget.categoryId);
    final bgColor = ColorGenerator.fromIdLowOpacity(budget.categoryId);

    final rawLimit = budget.limitAmount;
    final convertedLimit = rawLimit.toConverted(settings);

    return categoriesAsync.when(
      loading: () => const SizedBox(height: 70),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        final category = list.cast<Category?>().firstWhere(
          (c) => c?.id == budget.categoryId,
          orElse: () => null,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.white10),
          ),
          child: ListTile(
            onTap: () => context.pushNamed('budget-detail', extra: budget),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category?.icon ?? Icons.category,
                color: categoryColor,
              ),
            ),
            title: Text(
              category?.name ?? "Unknown Category",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Limit: ${CurrencyFormatter.formatLocaleCompact(amount: convertedLimit, symbol: settings.currencySymbol, currencyCode: settings.currency)}",
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }
}
