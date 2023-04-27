import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tootaloo/ui/components/admin_bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

class PostJudgementScreen extends StatefulWidget {
  const PostJudgementScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PostJudgementState();
}

class _PostJudgementState extends State<PostJudgementScreen> {
  final _index = 1;
  bool _loaded = false;
  late List<Rating> _reportedRatings;
  late Map<String, String> _userIds;

  @override
  void initState() {
    super.initState();
    _reportedRatings = [];
    getReportedRatings().then((ratings) => {
          setState(() {
            ratings.sort((a, b) => b.reports.compareTo(a.reports));
            _reportedRatings = ratings;
            _loaded = true;
          })
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
    }
    return Scaffold(
      backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
      appBar: const TopNavBar(title: "Rating Judgement"),
      body: Stack(
        children: _reportedRatings.isEmpty
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
                              "No more reported posts! Try again later!"))),
                ),
              ]
            : [
                RatingDisplayItem(
                  username: _reportedRatings.first.by,
                  reports: _reportedRatings.first.reports,
                  review: _reportedRatings.first.review,
                  bathroom: _reportedRatings.first.room,
                ),
                Positioned(
                    top: MediaQuery.of(context).size.height / 2.5 + 180,
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
                                      child: Text("Approve Post")),
                                  IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          _reportedRatings.removeAt(0);
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
                                      child: Text("Delete Post")),
                                  IconButton(
                                      onPressed: () async {
                                        await deletePost(
                                            _reportedRatings.first.id,
                                            _reportedRatings.first.by_id);
                                        setState(() {
                                          _reportedRatings.removeAt(0);
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

  Future<bool> deletePost(String ratingId, String userId) async {
    final response = await http.post(
      Uri.parse(
          'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/delete_post/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'id': ratingId, 'user_id': userId}),
    );
    return true;
  }

  Future<List<Rating>> getReportedRatings() async {
    String url =
        "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/reported-ratings/";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, List<String>>{
          'ids[]': [],
        }));
    dynamic responseData = json.decode(response.body);
    List<Rating> ratings = [];

    for (var rating in responseData) {
      Rating ratingData = Rating(
          id: rating["_id"].toString(),
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
          by_id: rating["by_id"].toString(),
          owned: false);
      print("BY ID: ${ratingData.by_id}");
      ratings.add(ratingData);
    }

    return ratings;
  }
}

class RatingDisplayItem extends StatefulWidget {
  final String username;
  final String bathroom;
  final num reports;
  final String review;
  const RatingDisplayItem(
      {super.key,
      required this.username,
      required this.bathroom,
      required this.reports,
      required this.review});

  @override
  _RatingDisplayItemState createState() => _RatingDisplayItemState();
}

class _RatingDisplayItemState extends State<RatingDisplayItem> {
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
                  child: Text("BATHROOM: ${widget.bathroom}"))),
        ),
        Positioned(
          top: 220,
          width: MediaQuery.of(context).size.width,
          child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              height: MediaQuery.of(context).size.height / 2.5 - 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(181, 211, 235, 1)),
              child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  child: Text("Review:\n ${widget.review}"))),
        ),
      ],
    );
  }
}

class Rating {
  final id;
  final String building;
  final String by;
  final String room;
  final String review;
  final String by_id;
  final num overallRating;
  final num internet;
  final num cleanliness;
  final num vibe;
  final num privacy;
  final int upvotes;
  final int downvotes;
  final int reports;
  bool owned;

  Rating(
      {required this.id,
      required this.building,
      required this.by,
      required this.room,
      required this.review,
      required this.overallRating,
      required this.internet,
      required this.cleanliness,
      required this.vibe,
      required this.privacy,
      required this.upvotes,
      required this.downvotes,
      required this.reports,
      required this.by_id,
      this.owned = false});
}
