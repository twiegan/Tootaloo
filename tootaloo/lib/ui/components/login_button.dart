import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/ui/screens/posts/trending_screen.dart';
import 'package:http/http.dart' as http;
import 'package:tootaloo/AppUser.dart';

class LoginButton extends StatelessWidget {
  String username;
  String password;

  LoginButton(
      {super.key,
      required String this.username,
      required String this.password});

  Future<String?> signIn(
      {required String username, required String password}) async {

    final bytes = utf8.encode(password);
    final passHash = sha256.convert(bytes);
    print("PASSHASH: $passHash");
    const String url = "http://127.0.0.1:8000/login/";
    final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'passHash': passHash.toString(),
        })
    );
    final tester = response.body.toString();
    print("RESPONSE BODY: $tester");
    return response.body.toString();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          print("EMAIL: $username  PASSWORD:  $password");

          String? response = await signIn(username: username, password: password);
          String responseVal = '';
          String userID = '';
          if (response != null) {
            List<String> resSplit = response.split(' ');
            responseVal = resSplit[0];
            userID = resSplit[1];
            print("ResponseVal: $responseVal, userID: $userID");
            
          }
            switch (responseVal) {
              case "good_login":
                print("Signed in!");
                UserPreferences.setUsername(username);
                UserPreferences.setId(userID);
                // AppUser currUser = await UserPreferences.getUser();
                // if(currUser.id != null) {
                //   print(currUser.id);
                // }
                // ignore: use_build_context_synchronously
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const TrendingScreen(
                    title: "Trending",
                  );
                }));
                break;
              case "bad_password":
                print("wrong password");
                break;
              case "user_dne":
                print("user does not exist");
                break;
            }
        },
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.black),
        ));
  }
}
