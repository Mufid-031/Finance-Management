import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneralSettingsPage extends ConsumerWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("General Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Currency",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 15),

          // Container pembungkus daftar mata uang agar terlihat modern
          Container(
            decoration: BoxDecoration(
              color: AppColors.widgetColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              children: [
                _buildCurrencyTile(ref, "US Dollar", "USD", "\$"),
                _buildDivider(),
                _buildCurrencyTile(ref, "Indonesian Rupiah", "IDR", "Rp"),
                _buildDivider(),
                _buildCurrencyTile(ref, "Euro", "EUR", "€"),
                _buildDivider(),
                _buildCurrencyTile(ref, "British Pound", "GBP", "£"),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            "Danger Zone",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 15),

          ListTile(
            onTap: () {
              // Logika clear data
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            leading: const Icon(
              Icons.delete_sweep_outlined,
              color: AppColors.red,
            ),
            title: const Text(
              "Clear Local Cache",
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTile(
    WidgetRef ref,
    String name,
    String code,
    String symbol,
  ) {
    final current = ref.watch(settingsProvider).currency;
    final isSelected = current == code;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        "$code ($symbol)",
        style: const TextStyle(color: AppColors.grey),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.main)
          : const Icon(Icons.circle_outlined, color: AppColors.grey),
      onTap: () {
        ref.read(settingsProvider.notifier).updateCurrency(code, symbol);
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: AppColors.white.withValues(alpha: 0.05),
    );
  }
}
