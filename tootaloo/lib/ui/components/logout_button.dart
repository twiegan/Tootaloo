import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';

class LogoutButton extends StatelessWidget {
  final FirebaseAuth firebaseAuth;
  const LogoutButton({super.key, required this.firebaseAuth});

  Future<void> signOut() async {
    await firebaseAuth.signOut();
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
