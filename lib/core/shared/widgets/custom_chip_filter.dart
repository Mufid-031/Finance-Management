import 'package:flutter/material.dart';
import 'package:finance_management/core/theme/app_colors.dart';

class CustomChipFilter<T extends Enum> extends StatelessWidget {
  final List<T> values;
  final T selectedValue;
  final Function(T) onSelected;
  final String Function(T) labelBuilder;

  const CustomChipFilter({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: values.map((value) {
          final isSelected = selectedValue == value;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => onSelected(value),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.main : AppColors.widgetColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.main
                        : AppColors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  labelBuilder(value).toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : AppColors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
