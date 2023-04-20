import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/post_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/ui/screens/review_screen.dart';

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
    return Scaffold(
      appBar: const TopNavBar(title: "Following"),
      body: Scaffold(
        appBar: const PostNavBar(title: "bitches", selectedIndex: 1),
        body: Center(
          child: ListView(
            // children: articles.map(_buildArticle).toList(),
            children:
                _ratings.map((rating) => ListTileItem(rating: rating)).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: index),
    );
  }
}

void _updateVotes(id, int votes, String type) async {
  final response = await http.post(
    Uri.parse('http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/update_votes/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'type': type,
      'id': id.toString(),
      'votes': votes.toString(),
    }),
  );
}

Future<bool> _checkVoted(ratingId) async {
  AppUser user = await UserPreferences.getUser();
  String userId = "";
  if (user.id == null) {
    return true;
  }
  userId = user.id!;
  final response = await http.post(
    Uri.parse('http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/check_votes/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body:
        jsonEncode(<String, String>{'rating_id': ratingId.toString(), 'user_id': userId}),
  );
  if (response.body.toString() == 'false') {
    return false;
  }
  return true;
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

Future<List<Rating>> _getRatings() async {
  // get the building markers from the database/backend
  // TODO: change this url later
  String url = "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/following_ratings/";
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
        upvotes: rating["upvotes"],
        downvotes: rating["downvotes"],
        owned: false);
    ratings.add(ratingData);
  }
  return ratings;
}

class ListTileItem extends StatefulWidget {
  final Rating rating;
  const ListTileItem({super.key, required this.rating});
  @override
  _ListTileItemState createState() => _ListTileItemState();
}

class _ListTileItemState extends State<ListTileItem> {
  int _upvotes = 0;
  int _downvotes = 0;
  @override
  Widget build(BuildContext context) {
    print("builtTile");
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
          color: Colors.white10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.08,
                                child: const Icon(Icons.account_circle)),
                            Text(widget.rating.by)
                          ],
                        ),
                        RatingBarIndicator(
                            rating: widget.rating.overallRating.toDouble(),
                            itemCount: 5,
                            itemSize: 20.0,
                            itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Color.fromARGB(255, 218, 196, 0),
                                ))
                      ])),
              Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.rating.building + widget.rating.room,
                        style: const TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Text(widget.rating.review))
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.arrow_upward,
                                  color: Colors.green),
                              onPressed: () {
                                if (_upvotes < 1) {
                                  _checkVoted(widget.rating.id).then((value) {
                                    if (!value) {
                                      setState(() {
                                        _upvotes += 1;
                                      });
                                      _updateVotes(
                                          widget.rating.id,
                                          widget.rating.upvotes + _upvotes,
                                          "upvotes");
                                    }
                                  });
                                }
                              },
                            ),
                            Text(
                              '${widget.rating.upvotes + _upvotes}',
                              style: const TextStyle(color: Colors.green),
                            )
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.arrow_downward,
                                  color: Colors.red),
                              onPressed: () {
                                if (_downvotes < 1) {
                                  _checkVoted(widget.rating.id).then((value) {
                                    if (!value) {
                                      setState(() {
                                        _downvotes += 1;
                                      });
                                      _updateVotes(
                                          widget.rating.id,
                                          widget.rating.downvotes + _downvotes,
                                          "downvotes");
                                    }
                                  });
                                }
                              },
                            ),
                            Text(
                              '${widget.rating.downvotes + _downvotes}',
                              style: const TextStyle(color: Colors.red),
                            )
                          ]),

                      // SizedBox(
                      //   height: 30,
                      //   width: 50,
                      if (widget.rating.owned)
                        TextButton(
                            onPressed: () {
                              String id = "";
                              if (widget.rating.id != null) {
                                id = widget.rating.id.toString();
                              }
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (BuildContext context,
                                      Animation<double> animation1,
                                      Animation<double> animation2) {
                                        return ReviewScreen(
                                            id: id);
                                      },
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(45, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft),
                            child: const Text("Edit"))
                      // )
                    ],
                  ))
            ],
          )),
    );
  }
}
