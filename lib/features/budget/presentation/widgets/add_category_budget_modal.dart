import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddCategoryBudgetModal extends ConsumerStatefulWidget {
  const AddCategoryBudgetModal({super.key});

  @override
  ConsumerState<AddCategoryBudgetModal> createState() =>
      _AddCategoryBudgetModalState();
}

class _AddCategoryBudgetModalState
    extends ConsumerState<AddCategoryBudgetModal> {
  String? selectedCategoryId;
  final limitController = TextEditingController();

  @override
  void dispose() {
    limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final budgetState = ref.watch(budgetNotifierProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: Text("Error: $err")),
      ),
      data: (categoryList) {
        final availableCategories = categoryList.where((cat) {
          final isExpense = cat.type == CategoryType.expense;
          final isNotAdded = !budgetState.categoryBudgets.any(
            (b) => b.categoryId == cat.id,
          );
          return isExpense && isNotAdded;
        }).toList();

        if (selectedCategoryId != null &&
            !availableCategories.any((cat) => cat.id == selectedCategoryId)) {
          selectedCategoryId = null;
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar di bagian atas modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.add_chart_rounded, color: AppColors.main),
                  SizedBox(width: 10),
                  Text(
                    "Add Category Budget",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              if (availableCategories.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      "No more expense categories available.",
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                )
              else ...[
                DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId,
                  isExpanded: true, // Mencegah overflow teks
                  decoration: InputDecoration(
                    labelText: "Select Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: availableCategories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 10, color: AppColors.main),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cat.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategoryId = val;
                    });
                  },
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: limitController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: "Limit Amount",
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixText: "${settings.currencySymbol} ",
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.main,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (selectedCategoryId != null &&
                          limitController.text.isNotEmpty) {
                        final limit =
                            double.tryParse(limitController.text) ?? 0;
                        final baseAmount = limit.toBase(settings);
                        final idToSave = selectedCategoryId;

                        context.pop();

                        await ref
                            .read(budgetNotifierProvider.notifier)
                            .addCategoryBudget(idToSave!, baseAmount);
                      }
                    },
                    child: const Text(
                      "Save Budget",
                      style: TextStyle(
                        color: AppColors.backgroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
