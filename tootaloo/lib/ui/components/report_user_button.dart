import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';

class ReportUserButton extends StatefulWidget {
  String type;
  String reportedUsername;
  ReportUserButton(
      {super.key,
      required String this.type,
      required String this.reportedUsername});

  @override
  _ReportUserButtonState createState() => _ReportUserButtonState();
}

class _ReportUserButtonState extends State<ReportUserButton> {
  bool _reported = false;

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

  void confirmReport(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible:
            false, // disables popup to close if tapped outside popup (need a button to close)
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(
                  Icons.flag,
                  color: Colors.orange,
                ),
                Text(
                  "Confirm Report",
                ),
              ],
            ),
            content: const Text(
              "Are you sure you want to report this user?",
            ),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  _updateReports(widget.reportedUsername, widget.type);
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                    side: MaterialStateProperty.all(const BorderSide(
                        color: Colors.orange,
                        width: 1.0,
                        style: BorderStyle.solid))),
                child: const Text("Confirm",
                    style: TextStyle(color: Colors.orange)),
                //closes popup
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, //closes popup
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)))),
                child: const Text("Close"),
              ),
            ],
          );
        });
  }

  void alreadyReported(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible:
            false, // disables popup to close if tapped outside popup (need a button to close)
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(
                  Icons.flag,
                  color: Colors.orange,
                ),
                Text(
                  "Already Reported",
                ),
              ],
            ),
            content: const Text(
              "This user has already been reported by you.",
            ),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, //closes popup
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)))),
                child: const Text("Close"),
              ),
            ],
          );
        });
  }

  void _updateReports(String reportedUsername, String type) async {
    final response = await http.post(
      Uri.parse(
          'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/update-user-reports/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'type': type,
        'reported_username': reportedUsername
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    print("inside reported button");
    _checkReported(widget.reportedUsername, "users").then((reported) => {
          setState(() {
            print(reported);
            _reported = reported;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(),
        icon: _reported
            ? const Icon(Icons.flag, color: Colors.orange)
            : const Icon(Icons.flag_outlined, color: Colors.orange),
        onPressed: () {
          _checkReported(widget.reportedUsername, widget.type).then((value) {
            if (!value) {
              confirmReport(context);
            } else {
              alreadyReported(context);
            }
          });
        });
  }
}
