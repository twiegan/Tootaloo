import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tootaloo/ui/components/admin_bottom_nav_bar.dart';
import 'package:tootaloo/ui/models/User.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import '../posts/following_screen.dart';

class UserJudgementScreen extends StatefulWidget {
  const UserJudgementScreen({super.key});

  @override
  State<StatefulWidget> createState() => _UserJudgementState();
}

class _UserJudgementState extends State<UserJudgementScreen> {
  final int _index = 0;
  late List<User> _users;
  bool _loaded = false;

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
      _users.sort((a, b) => a.reports.compareTo(b.reports)),
      _loaded = true,
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!_loaded) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
        appBar: const TopNavBar(title: "User Settings"),
        body: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical:250),
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
    }
    else {
      //TODO IMPLEMENT PROFILE VIEWING SCREEN
      return Scaffold(
        backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
        appBar: const TopNavBar(title: "User Settings"),
        body: UserDisplayItem(username: _users.first.username, post_ids:  _users.first.posts_ids.cast<String>(), reports: _users.first.reports),
        bottomNavigationBar: AdminBottomNavBar(
          selectedIndex: _index,
        ),
      );
    }

  }

  /* Get list of users that have been reported from the backend */
  Future<List<User>> _getReportedUsers() async {
    // Send request to backend and parse response
    String url =
        "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/reported-users/";

    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    print("GET USERS START");


    List<User> users = [];
    if (responseData == null) return users; // Sanity check

    for (var user in responseData) {
      User userData = User(
          id: user["_id"],
          username: user["username"],
          posts_ids: user["posts"],
          following_ids: user["following"],
          preference: '',
          reports: user["reports"]
      );

      print("ID: ${userData.id}, USERNAME: ${userData.username}, REPORTS: ${userData.reports}");
      users.add(userData);
    }

    return users;
  }

}

class UserDisplayItem extends StatefulWidget {
  final String username;
  final List<String> post_ids;
  final num reports;
  const UserDisplayItem({super.key, required this.username, required this.post_ids, required this.reports,});

  @override
  _UserDisplayItemState createState() => _UserDisplayItemState();
}

class _UserDisplayItemState extends State<UserDisplayItem> {
  late List<Rating> _currentRatings;
  Future<List<Rating>> _getRatings(List<String> ids) async {
    // Send request to backend and parse response
    // TODO: change this url later
    Map<String, dynamic> queryParams = {"ids[]": ids};
    Uri uri = Uri.http(
        dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'), "/ratings-by-ids/", queryParams);
    final response = await http.get(uri);
    dynamic responseData = json.decode(response.body);

    // Build rating list based on response
    List<Rating> ratings = [];

    for (var rating in responseData) {
      Rating ratingData = Rating(
          building: rating["building"],
          room: rating["room"],
          overall_rating: rating["overall_rating"],
          cleanliness: rating["cleanliness"],
          internet: rating["internet"],
          vibe: rating["vibe"],
          review: rating["review"],
          by: rating["by"]);
      ratings.add(ratingData);
    }

    return ratings;
  }

  @override
  void initState() {
    super.initState();
    _currentRatings = [];
    _getRatings(widget.post_ids).then((ratings) => {
      for (var rating in ratings)
        {
          setState(() {
            _currentRatings.add(rating);
          }),
        },
    });
  }

  @override
  Widget build(BuildContext context) {
    return
        Stack(
          children: [
            Positioned(
              top: 40,
              width: MediaQuery.of(context).size.width,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(181, 211, 235, 1)
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  child: Text("USERNAME: ${widget.username}")
                )
              ),
            ),
            Positioned(
              top: 100,
              width: MediaQuery.of(context).size.width,
              child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromRGBO(181, 211, 235, 1)
                  ),
                  child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      child: Text("REPORTS: ${widget.reports}")
                  )
              ),
            ),
            Positioned(
              top: 160,
              width: MediaQuery.of(context).size.width,
              child: Container(
                  margin: const EdgeInsets.only(left: 0, right: 0),
                  height: MediaQuery.of(context).size.height - 400,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromRGBO(181, 211, 235, 1)
                  ),
                // child: ListView(
                //   // children: articles.map(_buildArticle).toList(),
                //   children: _currentRatings.map((rating) => ListTileItem(rating: rating)).toList().cast<Widget>(),
                // ),
              ),
            )

          ],
        );
  }

}