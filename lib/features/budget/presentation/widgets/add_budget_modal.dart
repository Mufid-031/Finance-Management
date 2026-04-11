// lib/features/budget/presentation/widgets/add_budget_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/budget/presentation/providers/budget_provider.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:intl/intl.dart';

class AddBudgetModal extends ConsumerStatefulWidget {
  const AddBudgetModal({super.key});

  @override
  ConsumerState<AddBudgetModal> createState() => _AddBudgetModalState();
}

class _AddBudgetModalState extends ConsumerState<AddBudgetModal> {
  final amountController = TextEditingController();
  String? selectedCategoryId;
  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final expenseCategories =
        categoriesAsync.value
            ?.where((c) => c.type == CategoryType.expense)
            .toList() ??
        [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 10,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              "Set Monthly Budget",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 1. Pemilih Bulan (Budget Period)
            const Text(
              "Budget Period",
              style: TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.widgetColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.main,
                        ),
                        onPressed: () => setState(() {
                          selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month - 1,
                          );
                        }),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: AppColors.main,
                        ),
                        onPressed: () => setState(() {
                          selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month + 1,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Input Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.main,
              ),
              decoration: const InputDecoration(
                hintText: "0.00",
                prefixText: "\$ ",
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),

            // 3. Category Selector
            const Text(
              "Category",
              style: TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            if (expenseCategories.isEmpty)
              const Text(
                "No expense categories found.",
                style: TextStyle(color: AppColors.red),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: expenseCategories.map((c) {
                  final isSelected = selectedCategoryId == c.id;
                  return ChoiceChip(
                    avatar: Icon(
                      c.icon,
                      size: 16,
                      color: isSelected ? Colors.black : AppColors.main,
                    ),
                    label: Text(c.name),
                    selected: isSelected,
                    selectedColor: AppColors.main,
                    onSelected: (_) =>
                        setState(() => selectedCategoryId = c.id),
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),

            // 4. Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  "Confirm Budget",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (selectedCategoryId == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select category and enter valid amount"),
        ),
      );
      return;
    }

    await ref
        .read(budgetNotifierProvider.notifier)
        .saveBudget(
          categoryId: selectedCategoryId!,
          limit: amount,
          targetDate: selectedDate,
        );

    if (mounted) Navigator.pop(context);
  }
}
