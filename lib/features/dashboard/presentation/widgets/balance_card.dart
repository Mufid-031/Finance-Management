import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      // ... dekorasi tetap sama
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Balance", style: TextStyle(fontSize: 26)),
          Text(
            "\$${balance.toStringAsFixed(2)}", // Data dinamis
            style: const TextStyle(
              fontSize: 56,
              color: AppColors.main,
              fontWeight: FontWeight.bold,
            ),
          ),
          // ... sisanya
        ],
      ),
    );
  }
}
