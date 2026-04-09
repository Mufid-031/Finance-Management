import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Lebih merata
            children: [
              _actionIcon(
                context,
                Icons.category_outlined,
                "Category",
                AppColors.main, // Konsisten dengan brand color Anda
                onTap: () => context.push('/categories'),
              ),
              _actionIcon(
                context,
                Icons.account_balance_wallet_outlined,
                "Wallet",
                AppColors.blue,
                onTap: () => context.push('/wallets'),
              ),
              _actionIcon(
                context,
                Icons.pie_chart_outline_rounded,
                "Budget",
                AppColors.orange,
                onTap: () => context.push(
                  '/budgets',
                ), // Pastikan path ini terdaftar di router
              ),
              _actionIcon(
                context,
                Icons.analytics_outlined, // Berubah dari Bill ke Analytics
                "Reports",
                AppColors.green,
                onTap: () => context.push('/reports'),
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
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(
              15,
            ), // Ukuran touch target yang lebih baik
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
