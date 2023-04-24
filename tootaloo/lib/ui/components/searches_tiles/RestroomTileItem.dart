import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/models/restroom.dart';
import 'package:tootaloo/ui/screens/searches/ratings_view_screen.dart';

/* Define the tile itself */
class RestroomTileItem extends StatefulWidget {
  final Restroom restroom;
  const RestroomTileItem({super.key, required this.restroom});
  @override
  _RestroomTileItemState createState() => _RestroomTileItemState();
}

/* Define tile state */
class _RestroomTileItemState extends State<RestroomTileItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
          color: Colors.white10,
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.airline_seat_legroom_extra,
                            size: 40,
                          ),
                          Text(
                            "${widget.restroom.building}-${widget.restroom.room}-${widget.restroom.floor}",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                  'Cleanliness: ${widget.restroom.cleanliness}',
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Internet: ${widget.restroom.internet}',
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Vibe: ${widget.restroom.vibe}',
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ]),
                IntrinsicHeight(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${widget.restroom.rating}',
                            style: const TextStyle(fontSize: 30)),
                        const Icon(Icons.star,
                            color: Color.fromARGB(255, 224, 202, 0), size: 30),
                      ],
                    ),
                    Flexible(
                      flex: 5,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Reviews', style: TextStyle(fontSize: 20)),
                          IconButton(
                              icon: const Icon(Icons.arrow_circle_right_rounded,
                                  color: Colors.blue, size: 20),
                              onPressed: () async {
                                getRating(widget.restroom.ratings_ids
                                        .map((item) =>
                                            item.values.single as String)
                                        .toList())
                                    .then((ratings) => {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (BuildContext
                                                      context,
                                                  Animation<double> animation1,
                                                  Animation<double>
                                                      animation2) {
                                                return RatingsViewScreen(
                                                    title:
                                                        "${widget.restroom.building}-${widget.restroom.room} Reviews",
                                                    ratings: ratings);
                                              },
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          )
                                        });
                              })
                        ],
                      ),
                    ),
                  ],
                ))
              ])),
    );
  }
}

/* Get list of ratings the user searches for from the backend */
Future<List<Rating>> getRating(List<String> ids) async {
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
        id: "",
        building: rating["building"],
        room: rating["room"],
        overallRating: rating["overall_rating"],
        cleanliness: rating["cleanliness"],
        internet: rating["internet"],
        upvotes: 0,
        downvotes: 0,
        vibe: rating["vibe"],
        review: rating["review"],
        by: rating["by"],
        owned: false);
    ratings.add(ratingData);
  }

  return ratings;
}