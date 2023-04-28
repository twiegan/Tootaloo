import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/ui/screens/admin/user_judgement_screen.dart';
import 'package:tootaloo/ui/screens/posts/trending_screen.dart';
import 'package:http/http.dart' as http;
import 'package:tootaloo/AppUser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginButton extends StatelessWidget {
  String username;
  String password;

  LoginButton(
      {super.key,
      required String this.username,
      required String this.password});

  Future<Map<String, dynamic>?> signIn(
      {required String username, required String password}) async {
    final bytes = utf8.encode(password);
    final passHash = sha256.convert(bytes);
    print("PASSHASH: $passHash");
    String url =
        "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/login/";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'passHash': passHash.toString(),
        }));

    print(jsonDecode(response.body));
    final string_response = jsonDecode(response.body);
    return string_response;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          print("EMAIL: $username  PASSWORD:  $password");

          var response = await signIn(username: username, password: password);
          String status = '';
          String userID = '';
          String bathroom_preference = '';
          if (response != null) {
            status = response!["status"].toString();
            userID = response!["user_id"].toString();
            bathroom_preference = response!["bathroom_preference"].toString();
          }
          switch (status) {
            case "good_login":
              print("Signed in!");
              UserPreferences.setUsername(username);
              UserPreferences.setId(userID);
              UserPreferences.setPreference(bathroom_preference);
              // AppUser currUser = await UserPreferences.getUser();
              // if(currUser.id != null) {
              //   print(currUser.id);
              // }
              // ignore: use_build_context_synchronously
              if (username == "shradmin") {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const UserJudgementScreen();
                }));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const TrendingScreen(
                    title: "Trending",
                  );
                }));
              }
              break;
            case "bad_password":
              print("wrong password");
              // TODO: add pop up
              // ignore: use_build_context_synchronously
              showPopupMessage(context, const Icon(Icons.error),
                  " Incorrect password", "Please try again");
              break;
            case "user_dne":
              print("user does not exist");
              // ignore: use_build_context_synchronously
              showPopupMessage(context, const Icon(Icons.error),
                  " User does not exist", "Please try again");
              break;
          }
        },
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.black),
        ));
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
}
