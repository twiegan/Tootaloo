import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/post_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/components/rating_tile.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key, required this.title});
  final String title;

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

late List<Rating> _ratings;

class _TrendingScreenState extends State<TrendingScreen> {
  final int index = 0;

  @override
  void initState() {
    super.initState();

    _ratings = [];
    _getRatings().then((ratings) => {
          for (var rating in ratings)
            {
              _userOwned(rating.id).then((owned) => {
                    setState(() {
                      rating.owned = owned;
                    })
                  }),
              setState(() {
                _ratings.add(rating);
              }),
            },
          _ratings.sort((a, b) => a.downvotes.compareTo(b.downvotes)),
          _ratings.sort((b, a) => a.upvotes.compareTo(b.upvotes)),
        });
  }

  @override
  Widget build(BuildContext context) {
    print("loading");
    return Scaffold(
      appBar: const TopNavBar(title: "Trending"),
      body: Scaffold(
        appBar: const PostNavBar(title: "bitches", selectedIndex: 0),
        body: Center(
          child: ListView(
            // children: articles.map(_buildArticle).toList(),
            children:
                _ratings.map((rating) => RatingTile(rating: rating, screen: "Trending",)).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: index),
    );
  }
}

Future<List<Rating>> _getRatings() async {
  String url =
      "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/ratings/";

  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body);

  List<Rating> ratings = [];
  for (var rating in responseData) {
    Rating ratingData = Rating(
        id: rating["_id"],
        building: rating["building"],
        by: rating["by"],
        room: rating["room"],
        review: rating["review"],
        overallRating: rating["overall_rating"],
        internet: rating["internet"],
        cleanliness: rating["cleanliness"],
        vibe: rating["vibe"],
        privacy: rating["privacy"],
        upvotes: rating["upvotes"],
        downvotes: rating["downvotes"],
        reports: rating["reports"],
        owned: false);
    ratings.add(ratingData);
  }
  return ratings;
}

Future<bool> _userOwned(ratingId) async {
  AppUser user = await UserPreferences.getUser();
  String userId = "";
  if (user.id == null) {
    return true;
  }
  userId = user.id!;
  final response = await http.post(
    Uri.parse(
        'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/post_owned/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'rating_id': ratingId.toString(), 'user_id': userId}),
  );
  if (response.body.toString() == 'false') {
    return false;
  }
  return true;
}