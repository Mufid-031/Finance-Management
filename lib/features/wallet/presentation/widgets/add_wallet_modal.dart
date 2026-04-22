import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/currency_helper.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddWalletModal extends ConsumerStatefulWidget {
  final Wallet? wallet;
  const AddWalletModal({super.key, this.wallet});

  @override
  ConsumerState<AddWalletModal> createState() => _AddWalletModalState();
}

class _AddWalletModalState extends ConsumerState<AddWalletModal> {
  late TextEditingController nameController;
  late TextEditingController balanceController;
  late int selectedIconCode;
  late String selectedCurrency;

  // Daftar Ikon yang bisa dipilih untuk Wallet
  final List<IconData> walletIcons = [
    Icons.account_balance_wallet,
    Icons.account_balance,
    Icons.credit_card,
    Icons.payments,
    Icons.savings,
    Icons.attach_money,
    Icons.account_box,
  ];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);

    nameController = TextEditingController(text: widget.wallet?.name);
    balanceController = TextEditingController(
      text: (widget.wallet?.balance ?? 0.0)
          .toConverted(settings)
          .toStringAsFixed(2),
    );
    selectedIconCode =
        widget.wallet?.iconCode ?? Icons.account_balance_wallet.codePoint;

    // BOSS, mata uang ikuti global settings
    selectedCurrency = settings.currency;
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 10,
      ),
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
                color: AppColors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            widget.wallet == null ? "Add New Wallet" : "Edit Wallet",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter your wallet details to keep track of your money.",
            style: TextStyle(color: AppColors.grey, fontSize: 13),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: nameController,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: "Wallet Name",
              labelStyle: const TextStyle(color: AppColors.grey),
              prefixIcon: const Icon(
                Icons.drive_file_rename_outline,
                color: AppColors.main,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.main),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText:
                  widget.wallet == null ? "Initial Balance" : "Current Balance",
              labelStyle: const TextStyle(color: AppColors.grey),
              prefixIcon: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.main,
              ),
              suffixText: selectedCurrency,
              suffixStyle: const TextStyle(
                color: AppColors.main,
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.main),
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "Select Visual Icon",
            style: TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: walletIcons.length,
              itemBuilder: (context, index) {
                final icon = walletIcons[index];
                final isSelected = selectedIconCode == icon.codePoint;
                return GestureDetector(
                  onTap: () =>
                      setState(() => selectedIconCode = icon.codePoint),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.main
                          : AppColors.widgetColor,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.main.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.black : AppColors.grey,
                      size: 26,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.main,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final inputAmount =
                      double.tryParse(balanceController.text) ?? 0.0;
                  final baseAmount = inputAmount.toBase(settings);

                  // BOSS, kita simpan saldo awal sesuai mata uang yang dipilih.
                  // Nantinya saat transaksi, baru kita konversi jika perlu.

                  await ref
                      .read(walletNotifierProvider.notifier)
                      .saveWallet(
                        id: widget.wallet?.id,
                        name: nameController.text,
                        balance: baseAmount,
                        iconCode: selectedIconCode,
                        currency: selectedCurrency,
                      );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text(
                "Save Wallet",
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
    );
  }
}
