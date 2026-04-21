import 'package:finance_management/core/utils/currency_helper.dart';
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
            "Tambah Transaksi",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Pilih metode input untuk mencatat pengeluaran Anda hari ini.",
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
    final theme = Theme.of(context);
    final filteredCategories = allCategories
        .where(
          (c) =>
              c.type.index ==
              (selectedType == TransactionType.transfer
                  ? 1
                  : selectedType.index),
        )
        .toList();

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
            const SizedBox(height: 10),

            if (txState.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  txState.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),

            Row(
              children: [
                _TypeButton(
                  label: "Expense",
                  type: TransactionType.expense,
                  current: selectedType,
                  onTap: (t) => setState(() {
                    selectedType = t;
                    selectedCategoryId = null;
                  }),
                ),
                const SizedBox(width: 8),
                _TypeButton(
                  label: "Income",
                  type: TransactionType.income,
                  current: selectedType,
                  onTap: (t) => setState(() {
                    selectedType = t;
                    selectedCategoryId = null;
                  }),
                ),
                const SizedBox(width: 8),
                _TypeButton(
                  label: "Transfer",
                  type: TransactionType.transfer,
                  current: selectedType,
                  onTap: (t) => setState(() {
                    selectedType = t;
                    selectedCategoryId = null;
                    selectedToWalletId = null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.main,
              ),
              decoration: InputDecoration(
                hintText: "0.00",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixText: "${settings.currencySymbol} ",
                border: InputBorder.none,
              ),
            ),
            TextField(
              controller: nameController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: selectedType == TransactionType.transfer
                    ? "Catatan (misal: Pindah tabungan)"
                    : "Catatan (misal: Makan siang)",
                hintStyle: const TextStyle(color: AppColors.grey),
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            _SectionTitle(
              selectedType == TransactionType.transfer
                  ? "Dari Dompet"
                  : "Sumber Dompet",
            ),
            _buildWalletSelector(
              wallets,
              selectedWalletId,
              (id) => setState(() => selectedWalletId = id),
            ),
            if (selectedType == TransactionType.transfer) ...[
              const SizedBox(height: 20),
              const _SectionTitle("Ke Dompet"),
              _buildWalletSelector(
                wallets.where((w) => w.id != selectedWalletId).toList(),
                selectedToWalletId,
                (id) => setState(() => selectedToWalletId = id),
              ),
            ],
            if (selectedType != TransactionType.transfer) ...[
              const SizedBox(height: 20),
              const _SectionTitle("Kategori"),
              _buildCategorySelector(
                filteredCategories,
                selectedCategoryId,
                (id) => setState(() => selectedCategoryId = id),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
                        "Konfirmasi",
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

  Widget _buildAIScreen(aiState, aiNotifier, {required Key key}) {
    final theme = Theme.of(context);
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader("AI Assistant"),
          const SizedBox(height: 20),
          const Icon(Icons.auto_awesome, color: AppColors.main, size: 50)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds, color: Colors.white24),
          const SizedBox(height: 15),
          Text(
            aiState.isListening ? "Mendengarkan..." : "Bicara pada BOSS AI",
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
                  ? "Contoh: 'Makan siang 50rb dari Cash'"
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
            child:
                Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: aiState.isListening
                            ? Colors.redAccent
                            : AppColors.main,
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
                        color: aiState.isListening
                            ? Colors.white
                            : Colors.black,
                        size: 32,
                      ),
                    )
                    .animate(target: aiState.isListening ? 1 : 0)
                    .scale(duration: 400.ms),
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

  Widget _buildWalletSelector(
    List<Wallet> wallets,
    String? selectedId,
    Function(String) onSelect,
  ) {
    final theme = Theme.of(context);
    if (wallets.isEmpty) return const Text("No wallets available");
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: wallets
            .map<Widget>(
              (w) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    w.name,
                    style: TextStyle(
                      color: selectedId == w.id
                          ? Colors.black
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  selected: selectedId == w.id,
                  onSelected: (_) => onSelect(w.id),
                  selectedColor: AppColors.main,
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCategorySelector(
    List<Category> categories,
    String? selectedId,
    Function(String) onSelect,
  ) {
    final theme = Theme.of(context);
    if (categories.isEmpty) return const Text("No categories available");
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories
            .map<Widget>(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    c.name,
                    style: TextStyle(
                      color: selectedId == c.id
                          ? Colors.black
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  selected: selectedId == c.id,
                  onSelected: (_) => onSelect(c.id),
                  selectedColor: AppColors.main,
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
            )
            .toList(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi data dengan benar")),
      );
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
    final theme = Theme.of(context);
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
                  : AppColors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
