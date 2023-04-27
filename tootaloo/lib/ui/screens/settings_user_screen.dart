import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/logout_button.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/SharedPref.dart' as sharedPref;
import 'package:tootaloo/ui/screens/login_screen.dart';

import '../components/admin_bottom_nav_bar.dart';

class SettingsUserScreen extends StatefulWidget {
  const SettingsUserScreen({super.key, required this.title});
  final String title;

  @override
  State<SettingsUserScreen> createState() => _SettingsUserScreenState();
}

class _SettingsUserScreenState extends State<SettingsUserScreen> {
  final int index = -1;
  String _bathroom_preference = '';
  AppUser _user = AppUser(username: 'null', id: 'null');
  bool _loaded = false;

  Future<String?> saveSettings({required String bathroom_preference}) async {
    AppUser _user = await UserPreferences.getUser();
    String? _username = _user.username;
    String url =
        "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/save_user_settings/";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _username as String,
          'bathroom_preference': bathroom_preference,
        }));
    final tester = response.body.toString();
    return response.body.toString();
  }

  Future<void> _showAlertDialog(String alert) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text(''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(alert),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future pause(Duration d) => Future.delayed(d);

  Future<AppUser> _getUser() async {
    await pause(const Duration(milliseconds: 300));
    return await UserPreferences.getUser();
  }

  @override
  void initState() {
    _getUser().then((user) => {
          setState(() {
            _user = user;
            _loaded = true;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
        appBar: const TopNavBar(title: "User Settings"),
        body: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 200),
                child: Container(
                  height: 200,
                  width: 200,
                  child: const CircularProgressIndicator(
                    color: Color.fromRGBO(181, 211, 235, 1),
                    backgroundColor: Color.fromRGBO(223, 241, 255, 1),
                  ),
                ),
              ),
            ]),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: index,
        ),
      );
    }
    if (_user.username == 'null' && _user.id == 'null') {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
        appBar: const TopNavBar(title: "User Settings"),
        body: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 250),
                child: Container(
                  height: 75,
                  width: 350,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(181, 211, 235, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const LoginScreen();
                        }));
                      },
                      child: const Text(
                        "Log-In to Save Your Settings!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                        ),
                      )),
                ),
              ),
            ]),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: index,
        ),
      );
    } else if (_user.username == "shradmin") {
      return Scaffold(
          appBar: const TopNavBar(title: "Admin Logout"),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[LogoutButton()],
            ),
          ),
          bottomNavigationBar: const AdminBottomNavBar(
            selectedIndex: -1,
          ));
    }
    return Scaffold(
      appBar: const TopNavBar(title: "User Settings"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'User Settings!',
            ),
            DropdownSearch<String>(
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
            TextButton(
                onPressed: () async {
                  String? response = await saveSettings(
                      bathroom_preference: _bathroom_preference);
                  if (response != null) print("Response: $response");

                  switch (response) {
                    case "save_success":
                      // ignore: use_build_context_synchronously
                      sharedPref.UserPreferences.setPreference(
                          _bathroom_preference);
                      _showAlertDialog(
                          "Your Settings Were Saved Successfully!");
                      break;
                    case "save_fail":
                      //TODO IMPLEMENT ERROR POPUP
                      _showAlertDialog(
                          "Your Settings Were not Saved, Please try Again");
                      break;
                  }
                },
                child: const Text(
                  "Save Settings",
                  style: TextStyle(color: Colors.black),
                )),
            const LogoutButton()
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}
