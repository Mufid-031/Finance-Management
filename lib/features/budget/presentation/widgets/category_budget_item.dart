import 'package:finance_management/features/category/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class CategoryBudgetItem extends ConsumerWidget {
  final dynamic budget;
  const CategoryBudgetItem({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(height: 70),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        final category = list
            .cast<
              Category?
            >() // Tambahkan cast ke nullable agar orElse bisa return null
            .firstWhere((c) => c?.id == budget.categoryId, orElse: () => null);

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
                color: AppColors.main.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category?.icon ?? Icons.category,
                color: AppColors.main,
              ),
            ),
            title: Text(
              category?.name ?? "Unknown Category",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Limit: \$${budget.limitAmount.toStringAsFixed(2)}"),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }
}
