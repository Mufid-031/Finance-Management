import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

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
            fontWeight: FontWeight.bold,
            color: GFColors.DARK,
          ),
        ),
        Text(subtitle, style: TextStyle(fontSize: 16, color: GFColors.MUTED)),
      ],
    );
  }
}
