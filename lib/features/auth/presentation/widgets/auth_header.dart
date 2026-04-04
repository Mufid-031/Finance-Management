import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            color: AppColors.main,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(subtitle, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
