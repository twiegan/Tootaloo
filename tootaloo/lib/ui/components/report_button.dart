import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/ui/screens/posts/following_screen.dart';
import 'package:tootaloo/ui/screens/trending_screen.dart';

class Rating {
  final id;
  final String building;
  final String by;
  final String room;
  final String review;
  final num overallRating;
  final num internet;
  final num cleanliness;
  final num vibe;
  final int upvotes;
  final int downvotes;

  Rating({
    required this.id,
    required this.building,
    required this.by,
    required this.room,
    required this.review,
    required this.overallRating,
    required this.internet,
    required this.cleanliness,
    required this.vibe,
    required this.upvotes,
    required this.downvotes,
  });
}

class ReportButton extends StatefulWidget {
  String type;
  Rating rating;
  ReportButton(
      {super.key, required String this.type, required Rating this.rating});

  @override
  _ReportButtonState createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  Future<bool> _checkReported(ratingId) async {
    AppUser user = await UserPreferences.getUser();
    String userId = "";
    if (user.id == null) {
      return true;
    }
    userId = user.id!;
    final response = await http.post(
      Uri.parse(
          'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/check_votes/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'rating_id': ratingId.toString(),
        'user_id': userId
      }),
    );
    if (response.body.toString() == 'false') {
      return false;
    }
    return true;
  }

  void _report(id, String type) async {
    final response = await http.post(
      Uri.parse(
          'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/report/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'type': type, 'id': id.toString()}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.flag_outlined, color: Colors.orange),
        onPressed: () {
          //_checkReported(widget.rating.id).then((value) {
            //if (!value) {
              _report(widget.rating.id, widget.type);
            //}
          //});
        });
  }
}
