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
import 'package:tootaloo/ui/screens/login_screen.dart';
import 'package:tootaloo/ui/components/rating_tile.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final int index = 0;

  late List<Rating> _ratings;

  AppUser _user = AppUser(username: 'null', id: 'null');
  bool _loaded = false;

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
        appBar: const TopNavBar(title: "Following"),
        body: const Scaffold(
          appBar: PostNavBar(title: "bitches", selectedIndex: 1),
          body: Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(181, 211, 235, 1),
              backgroundColor: Color.fromRGBO(223, 241, 255, 1),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(selectedIndex: index),
      );
    }
    if (_user.username == 'null' && _user.id == 'null') {
      return Scaffold(
        appBar: const TopNavBar(title: "Following"),
        body: Scaffold(
          appBar: const PostNavBar(title: "bitches", selectedIndex: 1),
          body: Center(
            child: Padding(
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
                      "Log-In to Follow Your Friends!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    )),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(selectedIndex: index),
      );
    }
    return Scaffold(
      appBar: const TopNavBar(title: "Following"),
      body: Scaffold(
        appBar: const PostNavBar(title: "bitches", selectedIndex: 1),
        body: Center(
          child: ListView(
            // children: articles.map(_buildArticle).toList(),
            children:
                _ratings.map((rating) => RatingTile(rating: rating, screen: "Following",)).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: index),
    );
  }
}

Future pause(Duration d) => Future.delayed(d);

Future<AppUser> _getUser() async {
  await pause(const Duration(milliseconds: 700));
  return await UserPreferences.getUser();
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
    print("false");
    return false;
  }
  print("true");
  return true;
}

Future<List<Rating>> _getRatings() async {
  AppUser user = await UserPreferences.getUser();
  String userId = "";
  if (user.id == null || user.id == "") {
    //TODO: add popup to notify user must be logged in
    return [];
  }
  userId = user.id!;
  String url =
      "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/following_ratings/";
  final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': userId,
      }));
  if (response.body.toString() == "No user_id") {
    return [];
  }
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
    );
    ratings.add(ratingData);
  }
  return ratings;
}
