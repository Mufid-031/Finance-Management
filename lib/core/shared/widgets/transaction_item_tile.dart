import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/currency_formatter.dart';
import 'package:finance_management/core/utils/string_extension.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import ini

class TransactionItemTile extends StatelessWidget {
  final Transaction tx;
  final Category category;

  const TransactionItemTile({
    super.key,
    required this.tx,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == TransactionType.expense;

    // Format tanggal yang user friendly
    final formattedDate = DateFormat('d MMM yyyy').format(tx.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.backgroundColor,
            child: Icon(category.icon, color: AppColors.main, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name.capitalize(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tx.title.titleCase(),
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Rata kanan agar rapi
            children: [
              Text(
                "${isExpense ? '-' : '+'} ${CurrencyFormatter.format(tx.amount)}",
                style: TextStyle(
                  color: isExpense ? AppColors.red : AppColors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                formattedDate, // Gunakan hasil format intl
                style: const TextStyle(color: AppColors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
