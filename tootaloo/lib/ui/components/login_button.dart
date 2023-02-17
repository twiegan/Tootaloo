import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/trending_screen.dart';
import '../../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginButton extends StatelessWidget {
  LoginButton({super.key, this.email, this.password});

  var email;
  var password;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          try {
            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: password
            );
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const TrendingScreen(title: "Trending");
            }));
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              print('No user found for that email.');
            } else if (e.code == 'wrong-password') {
              print('Wrong password provided for that user.');
            }
          }
        },
        child: const Text("Login", style: TextStyle(color: Colors.black),));
  }
}
