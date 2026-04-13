import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double totalLimit;
  final double allocated;

  const BudgetSummaryCard({
    super.key,
    required this.totalLimit,
    required this.allocated,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalLimit - allocated;
    final percent = totalLimit > 0 ? (allocated / totalLimit) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text(
            "Total Monthly Budget",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            // UBAH Rp KE $ DAN TAMBAHKAN 2 DESIMAL
            "\$${totalLimit.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: percent > 1.0 ? 1.0 : percent,
            backgroundColor: Colors.white24,
            color: percent > 1.0 ? Colors.redAccent : Colors.white,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfo("Allocated", allocated),
              _buildInfo("Remaining", remaining),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
