import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> signOut() async {
    print("singout");
    //TODO IMPLEMENT SIGN OUT
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
