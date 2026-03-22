import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputAction? textInputAction;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return GFTextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: GFColors.DARK),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: GFColors.DARK),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: GFColors.FOCUS),
        ),
      ),
    );
  }
}
