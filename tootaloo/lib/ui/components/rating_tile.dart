import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/ui/components/report_post_button.dart';
import 'package:tootaloo/ui/screens/posts/following_screen.dart';
import 'package:tootaloo/ui/screens/review_screen.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/screens/posts/trending_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:tootaloo/ui/screens/searches/ratings_view_screen.dart';

void confirmDelete(
    BuildContext context, String id, String screen, Rating rating) {
  showDialog(
      context: context,
      barrierDismissible:
          false, // disables popup to close if tapped outside popup (need a button to close)
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red),
              Text(
                "Confirm Remove",
              ),
            ],
          ),
          content: const Text("Are you sure you want to remove this post?"),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                deletePost(id).then((ret) => {
                      if (screen == "Trending")
                        {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (BuildContext context,
                                  Animation<double> animation1,
                                  Animation<double> animation2) {
                                return const TrendingScreen(title: "Trending");
                              },
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          ),
                        }
                      else if (screen == "Following")
                        {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (BuildContext context,
                                  Animation<double> animation1,
                                  Animation<double> animation2) {
                                return const FollowingScreen(
                                    title: "Following");
                              },
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          ),
                        }
                      else
                        {
                          getRestroomByName(rating.building, rating.room)
                              .then((id) => {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (BuildContext context,
                                            Animation<double> animation1,
                                            Animation<double> animation2) {
                                          return RatingsViewScreen(
                                              title:
                                                  "${rating.building}-${rating.room} Reviews",
                                              id: id);
                                        },
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    ),
                                  })
                        }
                    });
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
                  side: MaterialStateProperty.all(const BorderSide(
                      color: Colors.red,
                      width: 1.0,
                      style: BorderStyle.solid))),
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.red),
              ),

//closes popup //closes popup
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

void confirmReport(BuildContext context, String id) {
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
            "Are you sure you want to report this post?",
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                checkReported(id, "rating").then((value) {
                  if (!value) {
                    updateReports(id, "rating");
                  }
                });
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
                  side: MaterialStateProperty.all(const BorderSide(
                      color: Colors.orange,
                      width: 1.0,
                      style: BorderStyle.solid))),
              child:
                  const Text("Confirm", style: TextStyle(color: Colors.orange)),
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

void _updateVotes(id, int votes, String type) async {
  final response = await http.post(
    Uri.parse(
        'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/update_votes/'),
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

Future<String> getRestroomByName(String building, String room) async {
  final response = await http.post(
    Uri.parse(
        'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/restroom_id_by_name/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'building': building, 'room': room}),
  );
  return json.decode(response.body)['id'].toString();
}

Future<bool> _checkVoted(ratingId) async {
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
    body: jsonEncode(
        <String, String>{'rating_id': ratingId.toString(), 'user_id': userId}),
  );
  if (response.body.toString() == 'false') {
    return false;
  }
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

class RatingTile extends StatefulWidget {
  final Rating rating;
  final String screen;
  const RatingTile({super.key, required this.rating, required this.screen});
  @override
  _RatingTileState createState() => _RatingTileState();
}

class _RatingTileState extends State<RatingTile> {
  int _upvotes = 0;
  int _downvotes = 0;
  bool _owned = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  Future<bool> changeDial(bool open) async {
    setState(() {
      isDialOpen.value = open;
    });
    return open;
  }

  void initState() {
    super.initState();

    _userOwned(widget.rating.id).then((owned) => {setState(() => _owned = owned)});
  }

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
                      Padding(
                          padding: const EdgeInsets.all(5),
                          child: SpeedDial(
                            backgroundColor: Color.fromARGB(255, 242, 242, 242),
                            foregroundColor: Colors.blue,
                            direction: SpeedDialDirection.up,
                            animatedIcon: AnimatedIcons.menu_close,
                            buttonSize: const Size(30, 30),
                            elevation: 0,
                            openCloseDial: isDialOpen,
                            closeManually: false,
                            children: [
                              if (_owned)
                                SpeedDialChild(
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    backgroundColor: Colors.blue,
                                    label: 'Edit',
                                    onTap: () {
                                      String id = "";
                                      if (widget.rating.id != null) {
                                        id = widget.rating.id.toString();
                                      }
                                      isDialOpen.value = false;
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (BuildContext context,
                                              Animation<double> animation1,
                                              Animation<double> animation2) {
                                            return ReviewScreen(id: id);
                                          },
                                          transitionDuration:
                                              const Duration(milliseconds: 200),
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                      // });
                                    }),
                              if (_owned)
                                SpeedDialChild(
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.red,
                                  label: 'Delete',
                                  onTap: () {
                                    String id = "";
                                    if (widget.rating.id != null) {
                                      id = widget.rating.id.toString();
                                    }
                                    confirmDelete(context, id, widget.screen,
                                        widget.rating);
                                  },
                                ),
                              SpeedDialChild(
                                child: const Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.orange,
                                label: 'Report',
                                onTap: () {
                                  String id = "";
                                  if (widget.rating.id != null) {
                                    id = widget.rating.id.toString();
                                  }
                                  confirmReport(context, id);
                                },
                              ),
                            ],
                          ))
                    ],
                  )),
                ])));
  }
}
