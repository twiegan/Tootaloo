// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordController2 = TextEditingController();
  final emailController = TextEditingController();
  final verificationCodeController = TextEditingController();

  var _username;
  var _password;
  var _password2;
  var _email;
  var _verificationCode;
  bool _loadingForVerification = false;
  String _bathroom_preference = "";
  String _correctVerificationCode = "";

  @override
  void initState() {
    super.initState();
    usernameController.addListener((refreshUsername));
    passwordController.addListener((refreshPassword));
    passwordController2.addListener((refreshPassword2));
    emailController.addListener((refreshEmail));
    verificationCodeController.addListener((refreshVerificationCode));
    _loadingForVerification = false;
  }

  bool validateEmail() {
    if (_email != null) {
      return RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(_email);
    }
    return true;
  }

  bool validateVerificationCode() {
    if (_verificationCode == null) {
      // no error message initially shown
      return true;
    }
    if (_verificationCode.toString().length != 4) {
      return false;
    }
    return true;
  }

  Future<String?> insertUser() async {
    final bytes = utf8.encode(_password!);
    final passHash = sha256.convert(bytes);
    String url =
        "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/insert_user/";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _username,
          'passHash': passHash.toString(),
          'bathroom_preference': _bathroom_preference,
          'email': _email,
        }));
    return response.body.toString();
  }

  void showPopupMessage(
      BuildContext context, Icon icon, String title, String text) {
    showDialog(
        context: context,
        barrierDismissible:
            false, // disables popup to close if tapped outside popup (need a button to close)
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                icon,
                Text(
                  title,
                ),
              ],
            ),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                }, //closes popup
              ),
            ],
          );
        });
  }

  _displayVerificationDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Check your email'),
              content: TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Code',
                  hintText: "Enter verification code",
                  errorText:
                      !validateVerificationCode() ? "Code is not valid" : null,
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                controller: verificationCodeController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: !validateVerificationCode()
                      ? null
                      : () async {
                          if (_verificationCode == _correctVerificationCode) {
                            await insertUser();

                            Navigator.of(context).pop();
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const LoginScreen();
                            }));
                            showPopupMessage(context, const Icon(Icons.check),
                                " Success", "Registered successfully");
                          } else {
                            showPopupMessage(context, const Icon(Icons.error),
                                " Error", "Entered verification code is wrong");
                          }
                        },
                  child: const Text('Verify'),
                )
              ],
            );
          });
        });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    verificationCodeController.dispose();
    super.dispose();
  }

  void refreshUsername() {
    _username = usernameController.text;
  }

  void refreshPassword() {
    _password = passwordController.text;
  }

  void refreshPassword2() {
    _password2 = passwordController2.text;
  }

  void refreshEmail() {
    _email = emailController.text;
  }

  void refreshVerificationCode() {
    _verificationCode = verificationCodeController.text;
  }

  Future<String?> signUp(
      {required String username, required String email}) async {
    String url =
        "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/user_register/";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
        }));

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
              padding: const EdgeInsets.only(top: 0.0, bottom: 0),
              child: SizedBox(
                  width: 240,
                  height: 150,
                  /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                  child: Image.asset('assets/images/tootaloo_logo.png',
                      fit: BoxFit.fill)),
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
                  left: 15.0, right: 15.0, top: 0, bottom: 15),
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
                  left: 15.0, right: 15.0, top: 0, bottom: 15),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  errorText:
                      !validateEmail() ? 'Email address is not valid' : null,
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: emailController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Container(
              height: 100,
              width: 420,
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 0, bottom: 15),
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
                  hintText: "Select Your Bathroom Preference",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                )),
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                    onPressed: () async {
                      if (_username == null || _username == "") {
                        print("EMPTY USERNAME");
                        showPopupMessage(context, const Icon(Icons.error),
                            " Error", "User name is empty");
                        return;
                      }

                      if (_password != _password2) {
                        print("MISMATCHED PASSWORDS");
                        showPopupMessage(context, const Icon(Icons.error),
                            " Error", "Passwords are not matching");
                        return;
                      }

                      if (_email == null || !validateEmail()) {
                        print("BAD EMAIL");
                        showPopupMessage(context, const Icon(Icons.error),
                            " Error", "Email is invalid");
                        return;
                      }

                      if (_bathroom_preference == "") {
                        print("NO PREFERENCE SELECTED");
                        showPopupMessage(context, const Icon(Icons.error),
                            " Error", "Preference is not selected");
                        return;
                      }

                      setState(() {
                        _loadingForVerification = true;
                      });
                      String? response = await signUp(
                          username: _username,
                          // password: _password,
                          // bathroom_preference: _bathroom_preference,
                          email: _email);
                      var responseData = json.decode(response!);

                      switch (responseData['status']) {
                        case "register_success":
                          setState(() {
                            _correctVerificationCode =
                                responseData['verification_code'].toString();
                          });
                          _displayVerificationDialog(context);

                          break;
                        case "username_taken":
                          print("USERNAME TAKEN ERROR");
                          showPopupMessage(context, const Icon(Icons.error),
                              " Error", "Entered username is taken");
                          break;
                        case "email_taken":
                          print("EMAIL TAKEN ERROR");
                          showPopupMessage(context, const Icon(Icons.error),
                              " Error", "Entered email is taken");
                          break;
                      }

                      setState(() {
                        _loadingForVerification = false;
                      });
                    },
                    child: _loadingForVerification
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Signup",
                            style: TextStyle(color: Colors.black),
                          )))
          ],
        ),
      ),
    );
  }
}
