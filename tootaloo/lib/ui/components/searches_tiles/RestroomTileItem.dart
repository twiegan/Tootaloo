import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tootaloo/ui/components/searches_tiles/RatingTileItem.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/models/restroom.dart';
import 'package:tootaloo/ui/screens/searches/ratings_view_screen.dart';

Future<List<Restroom>> getSearchedRestrooms(
    String building, String room, String floor) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {"building": building, "floor": floor};
  Uri uri =
      Uri.https("2ea4-128-210-106-52.ngrok.io", "/restrooms/", queryParams);
  final response = await http.get(uri);
  dynamic responseData = json.decode(response.body);

  // Build restroom list based on response
  List<Restroom> restrooms = [];
  if (responseData == null) return restrooms; // Sanity check

  for (var restroom in responseData) {
    Restroom restroomData = Restroom(
        building: restroom["building"],
        room: restroom["room"],
        floor: restroom["floor"],
        rating: restroom["rating"],
        cleanliness: restroom["cleanliness"],
        internet: restroom["internet"],
        vibe: restroom["vibe"],
        ratings_ids: restroom["ratings"]);

    restrooms.add(restroomData);
  }

  return restrooms;
}

class RestroomTileItem extends StatefulWidget {
  final Restroom restroom;
  const RestroomTileItem({super.key, required this.restroom});
  @override
  _RestroomTileItemState createState() => _RestroomTileItemState();
}

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
                                // List<Rating> ratings = (await getRating((widget
                                //         .restroom.ratings_ids)
                                //     .map((item) => item.values.single as String)
                                //     .toList()));

                                // List<RatingTileItem> ratingTileItems = [];

                                // for (Rating rating in ratings) {
                                // RatingTileItem ratingTileItem =
                                //     RatingTileItem(rating: rating);
                                // ratingTileItems.add(ratingTileItem);
                                // }

                                //~~~~~~

                                // Navigator.push(
                                //   context,
                                //   PageRouteBuilder(
                                //     pageBuilder: (BuildContext context,
                                //         Animation<double> animation1,
                                //         Animation<double> animation2) {
                                //       return RatingsViewScreen(
                                //           title:
                                //               "${widget.restroom.building}-${widget.restroom.room} Reviews",
                                //           ratingTileItems: ratingTileItems);
                                //     },
                                //     transitionDuration: Duration.zero,
                                //     reverseTransitionDuration: Duration.zero,
                                //   ),
                                // );

                                // for (var rating in ratings) {
                                //   setState(() {
                                //     RatingTileItem ratingTileItem =
                                //         RatingTileItem(rating: rating);
                                //     _ratings.add(ratingTileItem);
                                //   });
                                // }
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

/* Define Rating Tile Items */
class RatingTileItem extends StatefulWidget {
  final Rating rating;
  const RatingTileItem({super.key, required this.rating});
  @override
  _RatingTileItemState createState() => _RatingTileItemState();
}

class _RatingTileItemState extends State<RatingTileItem> {
  int _upvotes = 0;
  int _downvotes = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        color: Colors.white10,
        child: ListTile(
          contentPadding: const EdgeInsets.all(5),
          dense: true,
          leading:
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 40),
                Text(widget.rating.by)
              ],
            ),
            Flexible(
              flex: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, color: Color.fromARGB(255, 218, 196, 0)),
                  Icon(Icons.star, color: Color.fromARGB(255, 218, 196, 0)),
                  Icon(Icons.star, color: Color.fromARGB(255, 218, 196, 0)),
                  Icon(Icons.star),
                  Icon(Icons.star),
                ],
              ),
            ),
          ]),
          title: Text(
            "${widget.rating.building}-${widget.rating.room}",
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Text(widget.rating.review),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_upward, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          _upvotes += 1;
                        });
                      },
                    ),
                    Text(
                      '$_upvotes',
                      style: const TextStyle(color: Colors.green),
                    )
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_downward, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _downvotes += 1;
                        });
                      },
                    ),
                    Text(
                      '$_downvotes',
                      style: const TextStyle(color: Colors.red),
                    )
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
