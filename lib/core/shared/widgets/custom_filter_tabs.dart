import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class CustomFilterTabs extends StatelessWidget {
  final List<String> labels;
  final int currentIndex;
  final Function(int) onTabChanged;
  final EdgeInsets margin;

  const CustomFilterTabs({
    super.key,
    required this.labels,
    required this.currentIndex,
    required this.onTabChanged,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.main : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.black : AppColors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
