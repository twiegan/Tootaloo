import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';
import 'package:tootaloo/SharedPref.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> signOut() async {
    print("singout");
    UserPreferences.setUsername('null');
    UserPreferences.setId('null');
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          signOut();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const LoginScreen();
          }));
        },
        child: const Text("Logout"));
  }
}
