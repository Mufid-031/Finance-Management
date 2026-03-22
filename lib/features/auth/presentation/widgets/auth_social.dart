import 'package:flutter/material.dart';

class AuthSocial extends StatelessWidget {
  const AuthSocial({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("or continue with", style: TextStyle(color: Colors.grey)),
        SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.facebook, color: Colors.blueAccent),
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.apple)),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.g_mobiledata, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }
}
