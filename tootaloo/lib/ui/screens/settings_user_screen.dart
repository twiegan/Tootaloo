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


class SettingsUserScreen extends StatefulWidget {
  const SettingsUserScreen({super.key, required this.title});
  final String title;

  @override
  State<SettingsUserScreen> createState() => _SettingsUserScreenState();
}

class _SettingsUserScreenState extends State<SettingsUserScreen> {
  final int index = -1;
  String _bathroom_preference = '';

  Future<String?> saveSettings(
      {required String bathroom_preference}) async {
    AppUser _user = await UserPreferences.getUser();
    String? _username = _user.username;
    String url = "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/save_user_settings/";
    final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _username as String,
          'bathroom_preference': bathroom_preference,
        })
    );
    final tester = response.body.toString();
    print("RESPONSE BODY: $tester");
    return response.body.toString();
  }

  Future<void> _showAlertDialog(String alert) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog( // <-- SEE HERE
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

  @override
  Widget build(BuildContext context) {
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
                  )
              ),
              onChanged: (value) {
                _bathroom_preference = (value != null) ? value : '';
              },
              selectedItem: "",
            ),
            TextButton(
                onPressed: () async {

                  String? response =
                  await saveSettings(bathroom_preference: _bathroom_preference);
                  if (response != null) print("Response: $response");

                  switch (response) {
                    case "save_success":
                      // ignore: use_build_context_synchronously
                      _showAlertDialog("Your Settings Were Saved Successfully!");
                      break;
                    case "save_fail":
                      //TODO IMPLEMENT ERROR POPUP
                      _showAlertDialog("Your Settings Were not Saved, Please try Again");
                      break;
                  }
                },
                child: const Text(
                  "Save Settings",
                  style: TextStyle(color: Colors.black),
                )),
            const LogoutButton(
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}
