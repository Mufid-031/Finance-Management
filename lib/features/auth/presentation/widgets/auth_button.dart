import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AuthButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;

  const AuthButton({
    super.key,
    this.isLoading = false,
    this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : SizedBox(
            width: double.infinity,
            height: 50,
            child: GFButton(
              size: GFSize.LARGE,
              text: text,
              textStyle: TextStyle(
                fontSize: 16,
                color: GFColors.WHITE,
                fontWeight: FontWeight.bold,
              ),
              onPressed: onPressed,
            ),
          );
  }
}
