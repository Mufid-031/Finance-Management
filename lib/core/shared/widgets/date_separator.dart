import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class DateSeparator extends StatelessWidget {
  final String date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            date,
            style: const TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: AppColors.grey.withValues(alpha: 0.8),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
