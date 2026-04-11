import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  const AddTransactionModal({super.key});

  @override
  ConsumerState<AddTransactionModal> createState() =>
      _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  TransactionType selectedType = TransactionType.expense;
  String? selectedWalletId;
  String? selectedCategoryId;

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final txState = ref.watch(transactionNotifierProvider);

    final allCategories = categoriesAsync.value ?? [];
    final filteredCategories = allCategories
        .where((c) => c.type.index == selectedType.index)
        .toList();

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
              "New Transaction",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 1. Tipe Selector
            Row(
              children: [
                _TypeButton(
                  label: "Expense",
                  type: TransactionType.expense,
                  current: selectedType,
                  onTap: (type) => setState(() {
                    selectedType = type;
                    selectedCategoryId = null;
                  }),
                ),
                const SizedBox(width: 10),
                _TypeButton(
                  label: "Income",
                  type: TransactionType.income,
                  current: selectedType,
                  onTap: (type) => setState(() {
                    selectedType = type;
                    selectedCategoryId = null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Input Fields
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.main,
              ),
              decoration: const InputDecoration(
                hintText: "0.00",
                prefixText: "\$ ",
                border: InputBorder.none,
              ),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Notes (e.g. Lunch with friends)",
                border: InputBorder.none,
              ),
            ),
            const Divider(),

            // 3. Wallet Selector
            const _SectionTitle("Source Wallet"),
            walletsAsync.when(
              data: (list) => SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: list
                      .map(
                        (w) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(w.name),
                            selected: selectedWalletId == w.id,
                            onSelected: (_) =>
                                setState(() => selectedWalletId = w.id),
                            selectedColor: AppColors.main,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text("Error loading wallets"),
            ),

            const SizedBox(height: 20),

            // 4. Category Selector
            const _SectionTitle("Category"),
            if (filteredCategories.isEmpty)
              const Text(
                "No categories found.",
                style: TextStyle(color: AppColors.red, fontSize: 12),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredCategories
                    .map(
                      (c) => ChoiceChip(
                        avatar: Icon(
                          c.icon,
                          size: 16,
                          color: selectedCategoryId == c.id
                              ? Colors.black
                              : AppColors.main,
                        ),
                        label: Text(c.name),
                        selected: selectedCategoryId == c.id,
                        selectedColor: AppColors.main,
                        onSelected: (_) =>
                            setState(() => selectedCategoryId = c.id),
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 30),

            // 5. Confirm Button
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
                onPressed: txState.isLoading ? null : _submitData,
                child: txState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        "Confirm Transaction",
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

  void _submitData() async {
    if (selectedWalletId == null ||
        selectedCategoryId == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select wallet, category, and enter amount"),
        ),
      );
      return;
    }

    await ref
        .read(transactionNotifierProvider.notifier)
        .addTransaction(
          title: nameController.text.isEmpty ? "Untitled" : nameController.text,
          amount: double.tryParse(amountController.text) ?? 0,
          walletId: selectedWalletId!,
          categoryId: selectedCategoryId!,
          type: selectedType,
        );

    if (mounted) Navigator.pop(context);
  }
}

// --- Sub-widgets untuk menjaga kode tetap rapi ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        color: AppColors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

class _TypeButton extends StatelessWidget {
  final String label;
  final TransactionType type;
  final TransactionType current;
  final Function(TransactionType) onTap;

  const _TypeButton({
    required this.label,
    required this.type,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = type == current;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.main : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.main
                  : AppColors.grey.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
