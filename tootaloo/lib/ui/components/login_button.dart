import 'package:flutter/material.dart';

import 'package:tootaloo/ui/screens/trending_screen.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const TrendingScreen(
              title: "Trending",
            );
          }));
        },
        child: const Text("Login"));
  }
}
