import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tootaloo/ui/components/admin_bottom_nav_bar.dart';
import 'package:tootaloo/ui/models/User.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

class UserJudgementScreen extends StatefulWidget {
  const UserJudgementScreen({super.key});

  @override
  State<StatefulWidget> createState() => _UserJudgementState();
}

class _UserJudgementState extends State<UserJudgementScreen> {
  final int _index = 0;
  late List<User> _users;
  bool _loaded = false;
  late List<Rating> _currentRatings;

  @override
  void initState() {
    super.initState();

    _users = [];
    _getReportedUsers().then((users) => {
          for (var user in users)
            {
              setState(() {
                _users.add(user);
              })
            },
          _users.sort((a, b) => b.reports.compareTo(a.reports)),
          _currentRatings = [],
          _getRatings(_users.first.posts_ids
                  .map((item) => item.values.single as String)
                  .toList())
              .then((ratings) => {
                    for (var rating in ratings)
                      {
                        setState(() {
                          print(
                              "ID: ${rating.id}, BY: ${rating.by}, REVIEW: ${rating.review}");
                          _currentRatings.add(rating);
                        }),
                      },
                  }),
          _loaded = true,
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
        bottomNavigationBar: AdminBottomNavBar(
          selectedIndex: _index,
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
        appBar: const TopNavBar(title: "User Judgement"),
        body: Stack(
          children: _users.isEmpty
              ? [
                  Positioned(
                    top: 40,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        height: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromRGBO(181, 211, 235, 1)),
                        child: const DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            child: Text(
                                "No more reported users! Try again later!"))),
                  ),
                ]
              : [
                  UserDisplayItem(
                      username: _users.first.username,
                      ratings: _currentRatings,
                      reports: _users.first.reports),
                  Positioned(
                      top: MediaQuery.of(context).size.height / 3 + 240,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 20, right: 20),
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromRGBO(181, 211, 235, 1)),
                                child: Column(
                                  children: [
                                    const DefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.green,
                                        ),
                                        textAlign: TextAlign.center,
                                        child: Text("Approve User")),
                                    IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            _users.removeAt(0);
                                          });
                                          List<Rating> newRatings =
                                              await _getRatings(_users
                                                  .first.posts_ids
                                                  .map((item) => item
                                                      .values.single as String)
                                                  .toList());
                                          setState(() {
                                            _currentRatings = newRatings;
                                          });
                                        },
                                        alignment: Alignment.bottomCenter,
                                        icon: const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.green,
                                          size: 40,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 20, right: 20),
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromRGBO(181, 211, 235, 1)),
                                child: Column(
                                  children: [
                                    const DefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.red,
                                        ),
                                        textAlign: TextAlign.center,
                                        child: Text("Remove User")),
                                    IconButton(
                                        onPressed: () async {
                                          await _removeUser(
                                              _users.first.username);
                                          setState(() {
                                            _users.removeAt(0);
                                          });
                                          List<Rating> newRatings =
                                              await _getRatings(_users
                                                  .first.posts_ids
                                                  .map((item) => item
                                                      .values.single as String)
                                                  .toList());
                                          setState(() {
                                            _currentRatings = newRatings;
                                          });
                                        },
                                        alignment: Alignment.bottomCenter,
                                        icon: const Icon(
                                          Icons.cancel_rounded,
                                          color: Colors.red,
                                          size: 40,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ))
                ],
        ),
        bottomNavigationBar: AdminBottomNavBar(
          selectedIndex: _index,
        ),
      );
    }
  }

  Future<List<User>> _getReportedUsers() async {
    // Send request to backend and parse response
    String url =
        "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/reported-users/";

    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);

    List<User> users = [];
    if (responseData == null) return users; // Sanity check

    for (var user in responseData) {
      User userData = User(
        id: user["_id"],
        username: user["username"],
        posts_ids: user["posts"],
        following_ids: user["following"],
        preference: '',
        favorite_restrooms_ids: [],
        reports: user["reports"],
      );

      print(
          "ID: ${userData.id}, USERNAME: ${userData.username}, REPORTS: ${userData.reports}");
      users.add(userData);
    }
    print("GET USERS START");

    return users;
  }

  Future<List<Rating>> _getRatings(List<String> ids) async {
    // Send request to backend and parse response
    String url =
        "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/ratings-by-ids/";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, List<String>>{
          'ids[]': ids,
        }));
    dynamic responseData = json.decode(response.body);

    // Build rating list based on response
    List<Rating> ratings = [];

    for (var rating in responseData) {
      Rating ratingData = Rating(
          id: "",
          building: rating["building"],
          room: rating["room"],
          overallRating: rating["overall_rating"],
          cleanliness: rating["cleanliness"],
          internet: rating["internet"],
          upvotes: 0,
          downvotes: 0,
          vibe: rating["vibe"],
          privacy: rating["privacy"],
          review: rating["review"],
          by: rating["by"],
          reports: rating["reports"],
          owned: false);
      ratings.add(ratingData);
    }

    return ratings;
  }

  Future<void> _removeUser(String username) async {
    Map<String, dynamic> queryParams = {"username": username};
    Uri uri = Uri.http(
        dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
        "/remove-user/",
        queryParams);
    await http.post(uri);
  }
}

class UserDisplayItem extends StatefulWidget {
  final String username;
  final List<Rating> ratings;
  final num reports;
  const UserDisplayItem({
    super.key,
    required this.username,
    required this.ratings,
    required this.reports,
  });

  @override
  _UserDisplayItemState createState() => _UserDisplayItemState();
}

class _UserDisplayItemState extends State<UserDisplayItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 40,
          width: MediaQuery.of(context).size.width,
          child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(181, 211, 235, 1)),
              child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  child: Text("USERNAME: ${widget.username}"))),
        ),
        Positioned(
          top: 100,
          width: MediaQuery.of(context).size.width,
          child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(181, 211, 235, 1)),
              child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  child: Text("REPORTS: ${widget.reports}"))),
        ),
        Positioned(
          top: 160,
          width: MediaQuery.of(context).size.width,
          child: Container(
            margin: const EdgeInsets.only(left: 0, right: 0),
            height: MediaQuery.of(context).size.height / 2.5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(181, 211, 235, 1)),
            child: widget.ratings.isEmpty
                ? const Text(
                    "USER HAS NO POSTS",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30),
                  )
                : ListView(
                    children: widget.ratings
                        .map((rating) => RatingTile(rating: rating))
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class RatingTile extends StatefulWidget {
  final Rating rating;
  const RatingTile({super.key, required this.rating});
  @override
  _RatingTileState createState() => _RatingTileState();
}

class _RatingTileState extends State<RatingTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
            // color: Colors.white10,
            decoration: BoxDecoration(
                // color: const Color.fromARGB(255, 151, 187, 250),
                border: Border.all(
                    color: const Color.fromARGB(255, 227, 227, 227))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child: Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.08,
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
                                    )),
                          ]))),
                  Padding(
                      padding: const EdgeInsets.all(5),
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
                ])));
  }
}
