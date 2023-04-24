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
import 'package:tootaloo/ui/components/report_post_button.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/screens/login_screen.dart';

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
    if(!_loaded) {
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
    if(_user.username == 'null' && _user.id == 'null') {
      return Scaffold(
        appBar: const TopNavBar(title: "Following"),
        body: Scaffold(
          appBar: const PostNavBar(title: "bitches", selectedIndex: 1),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical:250),
              child: Container(
                height: 75,
                width: 350,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(181, 211, 235, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const LoginScreen();
                      }));
                    },
                    child: const Text(
                      "Log-In to Follow Your Friends!",
                      style: TextStyle(color:Colors.black, fontSize: 20,),
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
                _ratings.map((rating) => ListTileItem(rating: rating)).toList(),
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

Future<bool> deletePost(ratingId) async {
  AppUser user = await UserPreferences.getUser();
  String userId = "";
  if (user.id == null) {
    return false;
  }
  userId = user.id!;
  final response = await http.post(
    Uri.parse(
        'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/delete_post/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'id': ratingId.toString(), 'user_id': userId}),
  );
  return true;
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
      padding: const EdgeInsets.all(0),
      child: Container(
          // color: Colors.white10,
          decoration: BoxDecoration(
              // color: const Color.fromARGB(255, 151, 187, 250),
              border:
                  Border.all(color: const Color.fromARGB(255, 227, 227, 227))),
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
                                )),
                      ]))),
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
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.rating.owned) 
                        Expanded(
                            child: IconButton(
                                // constraints: BoxConstraints(
                                //   maxWidth: MediaQuery.of(context).size.width * 0.03,
                                // ),
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
                                        return ReviewScreen(id: id);
                                      },
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                style: IconButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  // minimumSize: Size(
                                  //     MediaQuery.of(context).size.width *
                                  //         0.04,
                                  //     MediaQuery.of(context).size.width *
                                  //         0.03),
                                  // tapTargetSize:
                                  //     MaterialTapTargetSize.shrinkWrap,
                                  // alignment: Alignment.centerLeft),
                                ),
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue, size: 16))),
                        if (widget.rating.owned) 
                        Expanded(
                            child: IconButton(
                                // constraints: BoxConstraints(
                                //   maxWidth: MediaQuery.of(context).size.width * 0.03,
                                // ),
                                onPressed: () {
                                  String id = "";
                                  if (widget.rating.id != null) {
                                    id = widget.rating.id.toString();
                                  }
                                  deletePost(id).then((ret) => {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (BuildContext context,
                                                Animation<double> animation1,
                                                Animation<double> animation2) {
                                              return const FollowingScreen(
                                                  title: "Trending");
                                            },
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        ),
                                      });
                                },
                                style: IconButton.styleFrom(
                                    padding: EdgeInsets.zero,

                                    // minimumSize: Size(
                                    //     MediaQuery.of(context).size.width *
                                    //         0.04,
                                    //     MediaQuery.of(context).size.width *
                                    //         0.03),
                                    // tapTargetSize:
                                    //     MaterialTapTargetSize.shrinkWrap,
                                    alignment: Alignment.centerLeft),
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 16))),
                        ReportPostButton(type: "rating", rating: widget.rating)
                      ],
                    )
                ],
              ))
            ],
          )),
    );
  }
}
