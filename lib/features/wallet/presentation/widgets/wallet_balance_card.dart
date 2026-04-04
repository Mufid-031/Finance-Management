import 'package:flutter/material.dart';

class WalletBalanceCard extends StatelessWidget {
  final double totalBalance;
  final VoidCallback? onAddTap;

  const WalletBalanceCard({
    super.key,
    required this.totalBalance,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Balance",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              IconButton(
                onPressed: onAddTap,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          Text(
            "\$${totalBalance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                "Income",
                "+\$0.00",
              ), // Nanti hubungkan ke Transaksi
              _buildInfoItem("Expense", "-\$0.00"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
