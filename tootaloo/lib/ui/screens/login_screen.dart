import 'package:flutter/material.dart';

import 'package:tootaloo/ui/components/login_button.dart';
import 'package:tootaloo/ui/screens/terms_of_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            const Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter valid email id as abc@gmail.com',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 15),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter secure password',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            // FlatButton(
            //   onPressed: (){
            //     //TODO FORGOT PASSWORD SCREEN GOES HERE
            //   },
            //   child: Text(
            //     'Forgot Password',
            //     style: TextStyle(color: Colors.blue, fontSize: 15),
            //   ),
            // ),
            const Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: Text("Forgot Password" //TODO FORGOT PASSWORD SCREEN,
                  ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const TermsOfServiceScreen();
                  }));
                },
                child: const Text("Terms Of Service")),
            Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(181, 211, 235, 1),
                    borderRadius: BorderRadius.circular(20)),
                child: const LoginButton()
                // child: FlatButton(
                //   onPressed: () {
                //     Navigator.push(
                //         context, MaterialPageRoute(builder: (_) => HomePage()));
                //   },
                //   child: Text(
                //     'Login',
                //     style: TextStyle(color: Colors.white, fontSize: 25),
                //   ),
                // ),
                ),
            const SizedBox(
              height: 130,
            ),
            const Text('New User? Create Account') //TODO CREATE ACCOUNT PAGE
          ],
        ),
      ),
    );
  }
}
