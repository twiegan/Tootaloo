import 'package:flutter/material.dart';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tootaloo/ui/screens/searches/restroom_search_screen.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/models/restroom.dart';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

// import 'package:tootaloo/ui/models/rating.dart';
// import 'package:tootaloo/ui/models/restroom.dart';
// import 'package:tootaloo/ui/screens/searches/restroom_search_screen.dart';
// import 'package:tootaloo/ui/components/searches_tiles/RestroomTileItem.dart';

// Row(
//     children: [
//       Column(
//         children: [
//           Expanded(
//               child: Center(
//             child: ListView(
//                 scrollDirection: Axis.vertical,
//                 shrinkWrap: true,
//                 children: _ratings),
//           ))
//         ],
//       )
//     ],
//   ),

class RatingsViewScreen extends StatefulWidget {
  const RatingsViewScreen(
      {super.key, required this.title, required this.ratings});

  final String title;
  final List<Rating> ratings;

  @override
  State<RatingsViewScreen> createState() => _RatingsViewScreenState();
}

class _RatingsViewScreenState extends State<RatingsViewScreen> {
  final int index = 0;

  @override
  Widget build(BuildContext context) {
    List<RatingTileItem> ratingTileItems = [];

    for (Rating rating in widget.ratings) {
      RatingTileItem ratingTileItem = RatingTileItem(rating: rating);
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

Future<List<Rating>> getRating(List<String> ids) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {"ids[]": ids};
  Uri uri = Uri.https(
      "2ea4-128-210-106-52.ngrok.io", "/ratings-by-ids/", queryParams);
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
