import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/rating_tile.dart';
import 'package:tootaloo/ui/models/restroom.dart';

class RatingsViewScreen extends StatefulWidget {
  const RatingsViewScreen({super.key, required this.title, required this.id});

  final String title;
  final String id;
  @override
  State<RatingsViewScreen> createState() => _RatingsViewScreenState();
}

class _RatingsViewScreenState extends State<RatingsViewScreen> {
  final int index = 2;
  late List<Rating> _ratings;

  @override
  void initState() {
    super.initState();

    _ratings = [];
    _getSearchedRestroom(widget.id).then((restroom) => {
          _getRatings(restroom.ratings_ids
                  .map((item) => item.values.single as String)
                  .toList())
              .then((ratings) => {
                    for (var rating in ratings)
                      {
                        setState(() {
                          _ratings.add(rating);
                        }),
                      },
                    _ratings.sort((a, b) => a.downvotes.compareTo(b.downvotes)),
                    _ratings.sort((b, a) => a.upvotes.compareTo(b.upvotes)),
                  })
        });
  }

  @override
  Widget build(BuildContext context) {
    List<RatingTile> ratingTileItems = [];

    for (Rating rating in _ratings) {
      RatingTile ratingTileItem =
          RatingTile(rating: rating, screen: "RatingViewScreen");
      ratingTileItems.add(ratingTileItem);
    }

    return Scaffold(
      appBar: TopNavBar(title: widget.title),
      body: Column(children: [
        ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: ratingTileItems)
      ]),
      bottomNavigationBar: BottomNavBar(selectedIndex: index),
    );
  }
}

/* Get list of ratings the user searches for from the backend */
Future<List<Rating>> _getRatings(List<String> ids) async {
  // Send request to backend and parse response
  // TODO: change this url later
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
        id: rating["_id"].values.first,
        building: rating["building"],
        room: rating["room"],
        overallRating: rating["overall_rating"],
        cleanliness: rating["cleanliness"],
        internet: rating["internet"],
        vibe: rating["vibe"],
        privacy: rating["privacy"],
        upvotes: rating["upvotes"],
        downvotes: rating["downvotes"],
        review: rating["review"],
        by: rating["by"],
        owned: false);
    ratings.add(ratingData);
  }

  return ratings;
}

/* Get list of restrooms the user searches for from the backend */
Future<Restroom> _getSearchedRestroom(String restroomId) async {
  // Send request to backend and parse response
  if (restroomId.contains("{")) {
    restroomId = restroomId.split(": ")[1].split("}")[0];
  }
  // Map<String, dynamic> queryParams = {
  //   "restroom_id": restroomId
  // };
  // Uri uri = Uri.http(
  //     dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
  //     "/restroom-by-id/",
  //     queryParams);
  // final response = await http.get(uri);
  String url =
      "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/restroom-by-id/";
  final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'restroom_id': restroomId,
      }));
  dynamic responseData = json.decode(response.body);

  Restroom restroom = Restroom(
      id: responseData["restroom"]["_id"].values.first,
      building: responseData["restroom"]["building"],
      room: responseData["restroom"]["room"],
      floor: responseData["restroom"]["floor"],
      rating: responseData["restroom"]["rating"],
      cleanliness: responseData["restroom"]["cleanliness"],
      internet: responseData["restroom"]["internet"],
      vibe: responseData["restroom"]["vibe"],
      privacy: responseData["restroom"]["privacy"],
      ratings_ids: responseData["restroom"]["ratings"]);

  return restroom;
}
