import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tootaloo/ui/components/login_button.dart';
import 'package:tootaloo/ui/screens/user_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  var email;
  var password;

  @override
  void initState() {
    super.initState();
    emailController.addListener((refreshEmail));
    passwordController.addListener((refreshPassword));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
      appBar: AppBar(
        title:
            const Text("Tootaloo Login", style: TextStyle(color: Colors.black)),
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
                  hintText: 'Enter secure password',
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: passwordController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            // const Padding(
            //   padding:
            //       EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 15),
            //   child: Text("Forgot Password" //TODO FORGOT PASSWORD SCREEN,
            //       ),
            // ),
            Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(181, 211, 235, 1),
                    borderRadius: BorderRadius.circular(20)),
                child: LoginButton(
                  email: emailController.text,
                  password: passwordController.text,
                  firebase_auth: firebaseAuth,
                )),
            const SizedBox(
              height: 100,
            ),
            TextButton(
                onPressed: () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const RegistrationScreen();
                      }))
                    },
                child: const Text(
                    'New User? Create Account')), //TODO CREATE ACCOUNT PAGE
          ],
        ),
      ),
    );
  }
}
