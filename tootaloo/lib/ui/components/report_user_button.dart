import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/ui/screens/posts/following_screen.dart';
import 'package:tootaloo/ui/screens/trending_screen.dart';

class ReportUserButton extends StatefulWidget {
  String type;
  String reportedUsername;
  ReportUserButton(
      {super.key, required String this.type, required String this.reportedUsername});

  @override
  _ReportUserButtonState createState() => _ReportUserButtonState();
}

class _ReportUserButtonState extends State<ReportUserButton> {
  Future<bool> _checkReported(String reportedUsername, String type) async {
    AppUser user = await UserPreferences.getUser();
    String userId = "";
    if (user.id == null) {
      return true;
    }
    userId = user.id!;
    final response = await http.post(
      Uri.parse(
          'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/check-user-reported/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'reported_username': reportedUsername,
        'user_id': userId,
        'type': type
      }),
    );
    if (response.body.toString() == 'false') {
      return false;
    }
    return true;
  }

  void _updateReports(String reportedUsername, String type) async {
    final response = await http.post(
      Uri.parse(
          'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/update-user-reports/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'type': type, 'reported_username': reportedUsername}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.flag_outlined, color: Colors.orange),
        onPressed: () {
          _checkReported(widget.reportedUsername, widget.type).then((value) {
            if (!value) {
              _updateReports(widget.reportedUsername, widget.type);
            }
          });
        });
  }
}
