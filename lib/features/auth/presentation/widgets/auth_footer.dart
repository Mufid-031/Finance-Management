import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AuthFooter extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const AuthFooter({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: TextStyle(fontSize: 15, color: GFColors.MUTED)),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionText,
            style: TextStyle(fontSize: 15, color: GFColors.PRIMARY),
          ),
        ),
      ],
    );
  }
}
