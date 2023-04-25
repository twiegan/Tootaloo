import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/ui/components/report_post_button.dart';
import 'package:tootaloo/ui/screens/review_screen.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/screens/posts/trending_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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

class RatingTile extends StatefulWidget {
  final Rating rating;
  const RatingTile({super.key, required this.rating});
  @override
  _RatingTileState createState() => _RatingTileState();
}

class _RatingTileState extends State<RatingTile> {
  int _upvotes = 0;
  int _downvotes = 0;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  Future<bool> changeDial(bool open) async {
    setState(() {
      isDialOpen.value = open;
    });
    return open;
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
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     if (widget.rating.owned)
                      //       Expanded(
                      //           child: IconButton(
                      //               // constraints: BoxConstraints(
                      //               //   maxWidth: MediaQuery.of(context).size.width * 0.03,
                      //               // ),
                      //               onPressed: () {
                      //                 String id = "";
                      //                 if (widget.rating.id != null) {
                      //                   id = widget.rating.id.toString();
                      //                 }
                      //                 Navigator.push(
                      //                   context,
                      //                   PageRouteBuilder(
                      //                     pageBuilder: (BuildContext context,
                      //                         Animation<double> animation1,
                      //                         Animation<double> animation2) {
                      //                       return ReviewScreen(id: id);
                      //                     },
                      //                     transitionDuration: Duration.zero,
                      //                     reverseTransitionDuration: Duration.zero,
                      //                   ),
                      //                 );
                      //               },
                      //               style: IconButton.styleFrom(
                      //                 padding: EdgeInsets.zero,
                      //                 // minimumSize: Size(
                      //                 //     MediaQuery.of(context).size.width *
                      //                 //         0.04,
                      //                 //     MediaQuery.of(context).size.width *
                      //                 //         0.03),
                      //                 // tapTargetSize:
                      //                 //     MaterialTapTargetSize.shrinkWrap,
                      //                 // alignment: Alignment.centerLeft),
                      //               ),
                      //               icon: const Icon(Icons.edit,
                      //                   color: Colors.blue, size: 16))),
                      //     if (widget.rating.owned)
                      //       Expanded(
                      //           child: IconButton(
                      //               // constraints: BoxConstraints(
                      //               //   maxWidth: MediaQuery.of(context).size.width * 0.03,
                      //               // ),
                      //               onPressed: () {
                      //                 String id = "";
                      //                 if (widget.rating.id != null) {
                      //                   id = widget.rating.id.toString();
                      //                 }
                      //                 deletePost(id).then((ret) => {
                      //                       Navigator.push(
                      //                         context,
                      //                         PageRouteBuilder(
                      //                           pageBuilder: (BuildContext context,
                      //                               Animation<double> animation1,
                      //                               Animation<double> animation2) {
                      //                             return const TrendingScreen(
                      //                                 title: "Trending");
                      //                           },
                      //                           transitionDuration: Duration.zero,
                      //                           reverseTransitionDuration:
                      //                               Duration.zero,
                      //                         ),
                      //                       ),
                      //                     });
                      //               },
                      //               style: IconButton.styleFrom(
                      //                   padding: EdgeInsets.zero,

                      //                   // minimumSize: Size(
                      //                   //     MediaQuery.of(context).size.width *
                      //                   //         0.04,
                      //                   //     MediaQuery.of(context).size.width *
                      //                   //         0.03),
                      //                   // tapTargetSize:
                      //                   //     MaterialTapTargetSize.shrinkWrap,
                      //                   alignment: Alignment.centerLeft),
                      //               icon: const Icon(Icons.delete,
                      //                   color: Colors.red, size: 16))),
                      //     if (!widget.rating.owned)
                      //       ReportPostButton(type: "rating", rating: widget.rating)
                      //   ],
                      // )
                      Padding(
                          padding: const EdgeInsets.all(5),
                          child: SpeedDial(
                            backgroundColor: Colors.blue,
                            direction: SpeedDialDirection.up,
                            animatedIcon: AnimatedIcons.menu_close,
                            buttonSize: const Size(30, 30),
                            elevation: 0,
                            openCloseDial: isDialOpen,
                            closeManually: false,
                            children: [
                              if (widget.rating.owned)
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
                              if (widget.rating.owned)
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

                                    deletePost(id).then((ret) => {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (BuildContext context,
                                                  Animation<double> animation1,
                                                  Animation<double> animation2) {
                                                return const TrendingScreen(
                                                    title: "Trending");
                                              },
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          ),
                                        });
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
                                  isDialOpen.value = false;

                                  checkReported(widget.rating.id, "rating")
                                      .then((value) {
                                    if (!value) {
                                      updateReports(widget.rating.id, "rating");
                                    }
                                  });
                                },
                              ),
                            ],
                          ))
                    ],
                  )),
                ])));
  }
}
