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
  bool owned;

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
    required this.owned,
  });
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
  Future<bool> _checkReported(ratingId, String type) async {
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

  void _updateReports(id, String type) async {
    final response = await http.post(
      Uri.parse(
          'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/update-rating-reports/'),
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
          _checkReported(widget.rating.id, widget.type).then((value) {
            if (!value) {
              _updateReports(widget.rating.id, widget.type);
            }
          });
        });
  }
}
