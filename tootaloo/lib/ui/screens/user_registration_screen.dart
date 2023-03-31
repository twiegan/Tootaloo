import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordController2 = TextEditingController();
  var email;
  var password;
  var password2;

  @override
  void initState() {
    super.initState();
    emailController.addListener((refreshEmail));
    passwordController.addListener((refreshPassword));
    passwordController2.addListener((refreshPassword2));
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern as String);
    return (!regex.hasMatch(value)) ? false : true;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void refreshEmail() {
    email = emailController.text;
  }

  void refreshPassword() {
    password = passwordController.text;
  }

  void refreshPassword2() {
    password2 = passwordController2.text;
  }

  // Future<String?> signUp(
  //     {required String email, required String password}) async {
  //   try {
  //     await firebaseAuth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     return "Signed up";
  //   } on FirebaseAuthException catch (e) {
  //     return e.message;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
      appBar: AppBar(
        title: const Text("Tootaloo Registration",
            style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0, bottom: 20),
              child: Center(
                child: SizedBox(
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset('assets/images/tootaloo_logo.png')),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter valid email id as abc@gmail.com',
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: emailController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter a secure password',
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: passwordController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Re-Enter Password',
                  hintText: 'Re-Enter Password',
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: passwordController2,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(181, 211, 235, 1),
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                    onPressed: () async {
                      if (!validateEmail(email)) {
                        print("BAD EMAIL");
                        return; //TODO add bad email popup window
                      }
                      if (password != password2) {
                        print("MISMATCHED PASSWORDS");
                        return; //TODO add mismatched passwords popup window
                      }
                      // String? response =
                      //     await signUp(email: email, password: password);
                      // if (response != null) print("Response: $response");
                      // switch (response) {
                      //   case "Signed up":
                      //     // ignore: use_build_context_synchronously
                      //     Navigator.push(context,
                      //         MaterialPageRoute(builder: (context) {
                      //       return const LoginScreen();
                      //     }));
                      // }
                    },
                    child: const Text(
                      "Signup",
                      style: TextStyle(color: Colors.black),
                    )))
          ],
        ),
      ),
    );
  }
}
