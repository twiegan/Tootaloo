import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/trending_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginButton extends StatelessWidget {
  String email;
  String password;
  FirebaseAuth firebase_auth;

  LoginButton(
      {super.key,
      required String this.email,
      required String this.password,
      required FirebaseAuth this.firebase_auth});

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      print("EMAIL AND PASSWORD: $email  ,  $password");
      await firebase_auth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      var errorCode = e.code;
      var errorMessage = e.message;

      if (errorCode == 'auth/wrong-password') {
        return ("Wrong Password.");
      } else {
        return errorMessage;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          print("EMAIL AND PASSWORD: " + email + "  :  " + password);

          String? response = await signIn(email: email, password: password);
          if (response != null) print("Response: " + response);
          switch (response) {
            case "Signed in":
              print("Signed in!");
              // ignore: use_build_context_synchronously
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const TrendingScreen(
                  title: "Trending",
                );
              }));
              break;
            case "Wrong Password.":
              print("wrong password");
              break;
          }
        },
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.black),
        ));
  }
}
