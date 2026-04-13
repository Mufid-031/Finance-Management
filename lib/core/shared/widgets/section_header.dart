import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  const SectionHeader({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed != null
            ? TextButton(onPressed: onPressed, child: const Text("See All"))
            : Container(),
      ],
    );
  }
}
