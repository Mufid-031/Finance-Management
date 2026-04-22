import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/core/utils/error_utils.dart';
import 'package:finance_management/features/ai_assistant/presentation/providers/ai_assistant_provider.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:finance_management/features/category/presentation/providers/category_provider.dart';
import 'package:finance_management/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';

enum InputSelection { none, manual, ai }

class AddTransactionModal extends ConsumerStatefulWidget {
  final Transaction? transaction;
  const AddTransactionModal({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionModal> createState() =>
      _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  late TextEditingController nameController;
  late TextEditingController amountController;

  InputSelection selection = InputSelection.none;
  TransactionType selectedType = TransactionType.expense;
  String? selectedWalletId;
  String? selectedToWalletId;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    final tx = widget.transaction;

    if (tx != null) {
      selection = InputSelection.manual;
      selectedType = tx.type;
      selectedWalletId = tx.walletId;
      selectedToWalletId = tx.toWalletId;
      selectedCategoryId = tx.categoryId;
    }

    nameController = TextEditingController(text: tx?.title);
    amountController = TextEditingController(
      text: tx != null
          ? (tx.amount * (settings.exchangeRate ?? 1.0)).toStringAsFixed(2)
          : "",
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final walletsAsync = ref.watch(walletsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final txState = ref.watch(transactionNotifierProvider);
    final aiState = ref.watch(aiAssistantProvider);
    final aiNotifier = ref.read(aiAssistantProvider.notifier);
    final theme = Theme.of(context);

    if (selection == InputSelection.manual &&
        selectedWalletId == null &&
        walletsAsync.value != null &&
        walletsAsync.value!.isNotEmpty) {
      selectedWalletId = walletsAsync.value!.first.id;
    }

    ref.listen(aiAssistantProvider, (previous, next) {
      if (previous?.isProcessing == true &&
          next.isProcessing == false &&
          next.resultMessage != null &&
          next.resultMessage!.contains("Recorded")) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: AnimatedSwitcher(
        duration: 300.ms,
        child: _buildContent(
          settings,
          walletsAsync.value ?? [],
          categoriesAsync.value ?? [],
          txState,
          aiState,
          aiNotifier,
        ),
      ),
    );
  }

  Widget _buildContent(
    settings,
    wallets,
    allCategories,
    txState,
    aiState,
    aiNotifier,
  ) {
    if (selection == InputSelection.none) {
      return _buildChoiceScreen(key: const ValueKey("choice"));
    } else if (selection == InputSelection.manual) {
      return _buildManualForm(
        settings,
        wallets,
        allCategories,
        txState,
        key: const ValueKey("manual"),
      );
    } else {
      return _buildAIScreen(aiState, aiNotifier, key: const ValueKey("ai"));
    }
  }

  Widget _buildChoiceScreen({required Key key}) {
    final theme = Theme.of(context);
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "New Transaction",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Select an input method to record your financial activity.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _ChoiceCard(
                  title: "Manual",
                  icon: Icons.edit_note,
                  color: AppColors.main,
                  onTap: () =>
                      setState(() => selection = InputSelection.manual),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _ChoiceCard(
                  title: "AI Agent",
                  icon: Icons.auto_awesome,
                  color: Colors.blueAccent,
                  onTap: () => setState(() => selection = InputSelection.ai),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildManualForm(
    settings,
    wallets,
    allCategories,
    txState, {
    required Key key,
  }) {
    final filteredCategories = allCategories
        .where(
          (c) =>
              c.type.index ==
              (selectedType == TransactionType.transfer
                  ? 1
                  : selectedType.index),
        )
        .toList();

    final Color accentColor = selectedType == TransactionType.expense
        ? AppColors.red
        : (selectedType == TransactionType.income
            ? AppColors.main
            : Colors.blueAccent);

    return Padding(
      key: key,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Manual Input"),
            const SizedBox(height: 20),

            // TYPE SELECTOR
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.widgetColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _TypeButton(
                    label: "Expense",
                    type: TransactionType.expense,
                    current: selectedType,
                    color: AppColors.red,
                    onTap: (t) => setState(() {
                      selectedType = t;
                      selectedCategoryId = null;
                    }),
                  ),
                  _TypeButton(
                    label: "Income",
                    type: TransactionType.income,
                    current: selectedType,
                    color: AppColors.main,
                    onTap: (t) => setState(() {
                      selectedType = t;
                      selectedCategoryId = null;
                    }),
                  ),
                  _TypeButton(
                    label: "Transfer",
                    type: TransactionType.transfer,
                    current: selectedType,
                    color: Colors.blueAccent,
                    onTap: (t) => setState(() {
                      selectedType = t;
                      selectedCategoryId = null;
                      selectedToWalletId = null;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // AMOUNT CARD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.widgetColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accentColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amount",
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                    decoration: InputDecoration(
                      hintText: "0.00",
                      hintStyle: TextStyle(color: accentColor.withValues(alpha: 0.2)),
                      prefixText: "${settings.currencySymbol} ",
                      prefixStyle: TextStyle(fontSize: 24, color: AppColors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // NOTE INPUT
            TextField(
              controller: nameController,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: "What's this for?",
                labelStyle: const TextStyle(color: AppColors.grey),
                hintText: selectedType == TransactionType.transfer
                    ? "Transfer note"
                    : "e.g. Dinner, Salary, etc.",
                prefixIcon: const Icon(Icons.description_outlined, color: AppColors.main),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.widgetColor,
              ),
            ),
            const SizedBox(height: 25),

            // WALLET & CATEGORY SELECTORS
            Row(
              children: [
                Expanded(
                  child: _buildCompactSelector(
                    label: selectedType == TransactionType.transfer ? "From" : "Wallet",
                    value: wallets
                        .where((w) => w.id == selectedWalletId)
                        .map((w) => w.name)
                        .firstWhere((_) => true, orElse: () => wallets.isNotEmpty ? wallets.first.name : "Select"),
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => _showWalletPicker(wallets),
                  ),
                ),
                if (selectedType == TransactionType.transfer) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactSelector(
                      label: "To",
                      value: selectedToWalletId != null
                          ? wallets.firstWhere((w) => w.id == selectedToWalletId).name
                          : "Select",
                      icon: Icons.login_rounded,
                      onTap: () => _showToWalletPicker(wallets),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactSelector(
                      label: "Category",
                      value: selectedCategoryId != null
                          ? allCategories
                              .firstWhere((c) => c.id == selectedCategoryId)
                              .name
                          : "Select",
                      icon: Icons.category_outlined,
                      onTap: () => _showCategoryPicker(filteredCategories),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildAIScreen(aiState, aiNotifier, {required Key key}) {
    final theme = Theme.of(context);
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader("Vantage AI"),
          const SizedBox(height: 20),
          const Icon(Icons.auto_awesome, color: AppColors.main, size: 50)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds, color: Colors.white24),
          const SizedBox(height: 15),
          Text(
            aiState.isListening ? "Listening..." : "Speak with Vantage AI",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: aiState.isListening
                    ? AppColors.main
                    : Colors.transparent,
              ),
              boxShadow: theme.brightness == Brightness.light
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              aiState.speechText.isEmpty
                  ? "Example: 'Lunch 50k from Cash'"
                  : aiState.speechText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: aiState.isListening
                    ? theme.colorScheme.onSurface
                    : AppColors.grey,
                fontStyle: aiState.speechText.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),

          const SizedBox(height: 20),
          if (aiState.isProcessing)
            const CircularProgressIndicator(color: AppColors.main),
          if (aiState.resultMessage != null)
            Text(
              aiState.resultMessage!,
              style: const TextStyle(
                color: AppColors.main,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(),

          const SizedBox(height: 30),

          GestureDetector(
            onTap: aiNotifier.toggleListening,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: aiState.isListening ? Colors.redAccent : AppColors.main,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (aiState.isListening
                                ? Colors.redAccent
                                : AppColors.main)
                            .withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                aiState.isListening ? Icons.stop : Icons.mic,
                color: aiState.isListening ? Colors.white : Colors.black,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.transaction == null)
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.grey,
            ),
            onPressed: () => setState(() => selection = InputSelection.none),
          )
        else
          const SizedBox(width: 40),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 40),
      ],
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.widgetColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.main),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletPicker(List<Wallet> wallets) {
    _showPickerModal(
      title: "Select Wallet",
      items: wallets.map((w) => _PickerItem(
        id: w.id,
        label: w.name,
        icon: IconData(w.iconCode, fontFamily: 'MaterialIcons'),
      )).toList(),
      selectedId: selectedWalletId,
      onSelect: (id) => setState(() => selectedWalletId = id),
    );
  }

  void _showToWalletPicker(List<Wallet> wallets) {
    _showPickerModal(
      title: "Transfer To",
      items: wallets
          .where((w) => w.id != selectedWalletId)
          .map((w) => _PickerItem(
                id: w.id,
                label: w.name,
                icon: IconData(w.iconCode, fontFamily: 'MaterialIcons'),
              ))
          .toList(),
      selectedId: selectedToWalletId,
      onSelect: (id) => setState(() => selectedToWalletId = id),
    );
  }

  void _showCategoryPicker(List<Category> categories) {
    _showPickerModal(
      title: "Select Category",
      items: categories.map((c) => _PickerItem(
        id: c.id,
        label: c.name,
        icon: c.icon,
      )).toList(),
      selectedId: selectedCategoryId,
      onSelect: (id) => setState(() => selectedCategoryId = id),
    );
  }

  void _showPickerModal({
    required String title,
    required List<_PickerItem> items,
    required String? selectedId,
    required Function(String) onSelect,
  }) {
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
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item.id == selectedId;
                  return ListTile(
                    onTap: () {
                      onSelect(item.id);
                      Navigator.pop(context);
                    },
                    leading: Icon(item.icon, color: isSelected ? AppColors.main : AppColors.grey),
                    title: Text(item.label, style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.main : Colors.white,
                    )),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.main) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitData() async {
    final bool isTransfer = selectedType == TransactionType.transfer;
    final String amountStr = amountController.text.replaceAll(',', '.');
    final double? inputAmount = double.tryParse(amountStr);

    if (selectedWalletId == null ||
        (!isTransfer && selectedCategoryId == null) ||
        (isTransfer && selectedToWalletId == null) ||
        inputAmount == null ||
        inputAmount <= 0) {
      ErrorUtils.showError(context, "Mohon lengkapi data dengan benar");
      return;
    }

    final settings = ref.read(settingsProvider);
    final baseAmount = inputAmount.toBase(settings);
    final categoryId = isTransfer ? "TRANSFER_CAT" : selectedCategoryId!;

    if (widget.transaction != null) {
      await ref
          .read(transactionNotifierProvider.notifier)
          .editTransaction(
            oldTx: widget.transaction!,
            title: nameController.text.isEmpty
                ? "Untitled"
                : nameController.text,
            amount: baseAmount,
            walletId: selectedWalletId!,
            toWalletId: selectedToWalletId,
            categoryId: categoryId,
            type: selectedType,
            date: widget.transaction!.date,
          );
    } else {
      await ref
          .read(transactionNotifierProvider.notifier)
          .addTransaction(
            title: nameController.text.isEmpty
                ? (isTransfer ? "Transfer" : "Untitled")
                : nameController.text,
            amount: baseAmount,
            walletId: selectedWalletId!,
            toWalletId: selectedToWalletId,
            categoryId: categoryId,
            type: selectedType,
          );
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted &&
          ref.read(transactionNotifierProvider).errorMessage == null) {
        Navigator.pop(context);
      }
    });
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ChoiceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: theme.brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerItem {
  final String id;
  final String label;
  final IconData icon;
  _PickerItem({required this.id, required this.label, required this.icon});
}

class _TypeButton extends StatelessWidget {
  final String label;
  final TransactionType type;
  final TransactionType current;
  final Color color;
  final Function(TransactionType) onTap;

  const _TypeButton({
    required this.label,
    required this.type,
    required this.current,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = type == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
