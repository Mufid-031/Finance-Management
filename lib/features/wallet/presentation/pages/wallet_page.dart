import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Wallets")),
      body: walletsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (wallets) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wallets.length,
          itemBuilder: (context, index) {
            final wallet = wallets[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.main,
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  wallet.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("\$${wallet.balance.toStringAsFixed(2)}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.grey),
                      onPressed: () =>
                          _showWalletDialog(context, ref, wallet: wallet),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.red),
                      onPressed: () => _confirmDelete(context, ref, wallet),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () => _showWalletDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // --- DIALOG UNTUK ADD & EDIT ---
  void _showWalletDialog(
    BuildContext context,
    WidgetRef ref, {
    Wallet? wallet,
  }) {
    final nameController = TextEditingController(text: wallet?.name);
    final balanceController = TextEditingController(
      text: wallet?.balance.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(wallet == null ? "Add Wallet" : "Edit Wallet"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Wallet Name"),
            ),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Initial Balance"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(walletNotifierProvider.notifier)
                  .saveWallet(
                    id: wallet?.id,
                    name: nameController.text,
                    balance: double.tryParse(balanceController.text) ?? 0,
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- KONFIRMASI HAPUS ---
  void _confirmDelete(BuildContext context, WidgetRef ref, Wallet wallet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Wallet"),
        content: Text("Are you sure you want to delete ${wallet.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(walletNotifierProvider.notifier)
                  .deleteWallet(wallet.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
