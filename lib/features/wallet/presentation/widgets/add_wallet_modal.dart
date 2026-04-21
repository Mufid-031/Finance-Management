import 'package:finance_management/core/theme/app_colors.dart';
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

  final List<String> currencies = ['USD', 'IDR', 'EUR', 'GBP', 'JPY'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wallet?.name);
    balanceController = TextEditingController(
      text: widget.wallet?.balance.toString(),
    );
    selectedIconCode =
        widget.wallet?.iconCode ?? Icons.account_balance_wallet.codePoint;
    selectedCurrency = widget.wallet?.currency ?? 'USD';
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Wallet Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Initial Balance",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: "Currency",
                    border: OutlineInputBorder(),
                  ),
                  items: currencies.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 12)),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedCurrency = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Select Icon",
            style: TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
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
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.main
                          : AppColors.widgetColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.main : Colors.transparent,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.black : AppColors.grey,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.main,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final inputAmount =
                      double.tryParse(balanceController.text) ?? 0.0;
                  
                  // BOSS, kita simpan saldo awal sesuai mata uang yang dipilih.
                  // Nantinya saat transaksi, baru kita konversi jika perlu.
                  
                  await ref
                      .read(walletNotifierProvider.notifier)
                      .saveWallet(
                        id: widget.wallet?.id,
                        name: nameController.text,
                        balance: inputAmount,
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
