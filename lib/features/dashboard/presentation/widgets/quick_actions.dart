import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Pastikan import ini ada

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionIcon(
                context,
                Icons.send,
                "Transfer",
                AppColors.orange,
                onTap: () =>
                    context.push('/transfer'), // Sesuaikan path router Anda
              ),
              _actionIcon(
                context,
                Icons.account_balance_wallet,
                "Wallet",
                AppColors.purple,
                onTap: () =>
                    context.push('/wallets'), // Link ke halaman Wallet baru
              ),
              _actionIcon(
                context,
                Icons.receipt_long,
                "Bill",
                AppColors.green,
                onTap: () => context.push('/bills'),
              ),
              _actionIcon(
                context,
                Icons.category,
                "Category",
                AppColors.blue,
                onTap: () => context.push('/categories'), // Untuk menu tambahan
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionIcon(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      // Menggunakan InkWell agar ada efek "splash" saat diklik
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Area klik sedikit lebih luas
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
