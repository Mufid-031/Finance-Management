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
    final convertedSpent = budget.spentAmount.toConverted(settings);
    final percent = convertedLimit > 0 ? (convertedSpent / convertedLimit) : 0.0;
    final isOverLimit = convertedSpent > convertedLimit;

    return categoriesAsync.when(
      loading: () => const SizedBox(height: 90),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        final category = list.cast<Category?>().firstWhere(
          (c) => c?.id == budget.categoryId,
          orElse: () => null,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.widgetColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOverLimit
                  ? AppColors.red.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => context.pushNamed('budget-detail', extra: budget),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category?.icon ?? Icons.category,
                          color: categoryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category?.name ?? "Unknown Category",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${(percent * 100).toStringAsFixed(0)}% used",
                              style: TextStyle(
                                color: isOverLimit ? AppColors.red : AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.formatLocaleCompact(
                              amount: convertedSpent,
                              symbol: settings.currencySymbol,
                              currencyCode: settings.currency,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isOverLimit ? AppColors.red : Colors.white,
                            ),
                          ),
                          Text(
                            "of ${CurrencyFormatter.formatLocaleCompact(
                              amount: convertedLimit,
                              symbol: settings.currencySymbol,
                              currencyCode: settings.currency,
                            )}",
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent > 1.0 ? 1.0 : percent,
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverLimit ? AppColors.red : categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
