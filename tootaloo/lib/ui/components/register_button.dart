import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';

class RegisterButton extends StatelessWidget {
  String email;
  String password;

  RegisterButton(
      {super.key,
      required String this.email,
      required String this.password,
      });

  Future<String?> signUp(
      {required String email, required String password}) async {
    // try {
    //   await firebase_auth.createUserWithEmailAndPassword(
    //       email: email, password: password);
    //   return "Signed up";
    // } on FirebaseAuthException catch (e) {
    //   return e.message;
    // }
    //TODO IMPLEMENT SIGNUP
    print("signup");
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          print("EMAIL AND PASSWORD: $email :  $password");

          String? response = await signUp(email: email, password: password);
          if (response != null) print("Response: $response");
          switch (response) {
            case "Signed up":
              // ignore: use_build_context_synchronously
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const LoginScreen();
              }));
              break;
          }
        },
        child: const Text(
          "Signup",
          style: TextStyle(color: Colors.black),
        ));
  }
}
