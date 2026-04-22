import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/error_utils.dart';
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
            color: Theme.of(context).scaffoldBackgroundColor,
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
              const Text(
                "Category Budget",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Set a monthly spending limit for a specific category.",
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
              const SizedBox(height: 30),

              if (availableCategories.isEmpty)
                _buildEmptyState()
              else ...[
                // CATEGORY SELECTOR
                _buildCompactSelector(
                  label: "Target Category",
                  value: selectedCategoryId != null
                      ? availableCategories
                          .firstWhere((c) => c.id == selectedCategoryId)
                          .name
                      : "Choose Category",
                  icon: Icons.category_outlined,
                  onTap: () => _showCategoryPicker(availableCategories),
                ),
                const SizedBox(height: 20),

                // AMOUNT CARD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.widgetColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.main.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Monthly Limit",
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      ),
                      TextField(
                        controller: limitController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "0.00",
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1)),
                          prefixText: "${settings.currencySymbol} ",
                          prefixStyle: const TextStyle(fontSize: 22, color: AppColors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.main,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    onPressed: (selectedCategoryId == null || limitController.text.isEmpty)
                        ? null
                        : () async {
                            final limit = double.tryParse(limitController.text) ?? 0;
                            final baseAmount = limit.toBase(settings);
                            final idToSave = selectedCategoryId;

                            await ref
                                .read(budgetNotifierProvider.notifier)
                                .addCategoryBudget(idToSave!, baseAmount);
                                
                            if (context.mounted) {
                              Navigator.pop(context);
                              ErrorUtils.showSuccess(context, "Budget plan saved!");
                            }
                          },
                    child: const Text(
                      "Save Budget Plan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.category_outlined, color: AppColors.grey, size: 40),
          SizedBox(height: 10),
          Text(
            "All categories already have budgets.",
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSelector({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.widgetColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.main.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.main),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(List<Category> categories) {
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
            const Text("Select Category",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat.id == selectedCategoryId;
                  return ListTile(
                    onTap: () {
                      setState(() => selectedCategoryId = cat.id);
                      Navigator.pop(context);
                    },
                    leading: Icon(cat.icon,
                        color: isSelected ? AppColors.main : AppColors.grey),
                    title: Text(cat.name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.main : Colors.white,
                        )),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.main)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
