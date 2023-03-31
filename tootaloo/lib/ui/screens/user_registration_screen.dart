import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordController2 = TextEditingController();
  var _username;
  var _password;
  var _password2;
  String _bathroom_preference = "";

  @override
  void initState() {
    super.initState();
    usernameController.addListener((refreshEmail));
    passwordController.addListener((refreshPassword));
    passwordController2.addListener((refreshPassword2));
  }

  // bool validateEmail(String value) {
  //   Pattern pattern =
  //       r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  //   RegExp regex = RegExp(pattern as String);
  //   return (!regex.hasMatch(value)) ? false : true;
  // }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void refreshEmail() {
    _username = usernameController.text;
  }

  void refreshPassword() {
    _password = passwordController.text;
  }

  void refreshPassword2() {
    _password2 = passwordController2.text;
  }

  Future<String?> signUp(
      {required String username, required String password, required String bathroom_preference}) async {
    final bytes = utf8.encode(password);
    final passHash = sha256.convert(bytes);
    print("PASSHASH: $passHash");
    const String url = "http://153.33.43.118:8000/user_register/";
    final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'passHash': passHash.toString(),
          'bathroom_preference': bathroom_preference,
        })
    );
    final tester = response.body.toString();
    print("RESPONSE BODY: $tester");
    return response.body.toString();
  }

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
                  labelText: 'Username',
                  hintText: 'Enter your new username!',
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: usernameController,
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
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  showSelectedItems: true,
                  showSearchBox: true,
                ),
                items: const ['male', 'female', 'unisex'],
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Bathroom Preference",
                    hintText: "Select Your Bathroom Preference"
                  )
                ),
                onChanged: (value) {
                  _bathroom_preference = (value != null) ? value : '';
                },
                selectedItem: "",
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
                      // if (!validateEmail(_username)) {
                      //   print("BAD EMAIL");
                      //   return; //TODO add bad email popup window
                      // }
                      if (_password != _password2) {
                        print("MISMATCHED PASSWORDS");
                        return; //TODO add mismatched passwords popup window
                      }
                      if (_bathroom_preference == "") {
                        print("NO PREFERENCE SELECTED");
                        return; //TODO add popup for no preference selected
                      }
                      String? response =
                          await signUp(username: _username, password: _password, bathroom_preference: _bathroom_preference);
                      if (response != null) print("Response: $response");

                      switch (response) {
                        case "register_success":
                          // ignore: use_build_context_synchronously
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const LoginScreen();
                          }));
                          break;
                        case "username_taken":
                          print("USERNAME TAKEN ERROR");
                          //TODO IMPLEMENT ERROR POPUP
                          break;
                      }
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
