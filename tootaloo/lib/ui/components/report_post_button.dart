import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/ui/models/rating.dart';


Future<bool> checkReported(ratingId, String type) async {
  AppUser user = await UserPreferences.getUser();
  String userId = "";
  if (user.id == null) {
    return true;
  }
  userId = user.id!;
  final response = await http.post(
    Uri.parse(
        'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/check-rating-reported/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'rating_id': ratingId.toString(),
      'user_id': userId,
      'type': type
    }),
  );
  if (response.body.toString() == 'false') {
    return false;
  }
  return true;
}

void updateReports(id, String type) async {
  final response = await http.post(
    Uri.parse(
        'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/update-rating-reports/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'type': type, 'id': id.toString()}),
  );
}


class ReportPostButton extends StatefulWidget {
  String type;
  Rating rating;
  ReportPostButton(
      {super.key, required String this.type, required Rating this.rating});

  @override
  _ReportPostButtonState createState() => _ReportPostButtonState();
}

class _ReportPostButtonState extends State<ReportPostButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.flag_outlined, color: Colors.orange, size: 16,),
        onPressed: () {
          checkReported(widget.rating.id, widget.type).then((value) {
            if (!value) {
              updateReports(widget.rating.id, widget.type);
            }
          });
        });
  }
}