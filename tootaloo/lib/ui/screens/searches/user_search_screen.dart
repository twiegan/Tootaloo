import 'package:flutter/material.dart';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/search_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

/* Define the screen itself */
class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key, required this.title});
  final String title;

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

/* Define screen state */
class _UserSearchScreenState extends State<UserSearchScreen> {
  final int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "User Search"),
      body: Scaffold(
        appBar: const SearchNavBar(title: "User Search", selectedIndex: 1),
        body: Column(children: [
          Center(
            child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.lightBlue)),
          ),
          Expanded(
              child: Center(
            child: ListView(
              // children: articles.map(_buildArticle).toList(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: List.generate(
                  20,
                  (index) => BathroomTileItem(
                        name:
                            '${faker.randomGenerator.fromCharSet('ABCDEFGHIJKLMONPESTUVWY', 3)}${faker.randomGenerator.integer(999)}',
                        cleanliness:
                            roundDouble(faker.randomGenerator.decimal() * 5, 1),
                        internet:
                            roundDouble(faker.randomGenerator.decimal() * 5, 1),
                        vibe:
                            roundDouble(faker.randomGenerator.decimal() * 5, 1),
                        rating:
                            roundDouble(faker.randomGenerator.decimal() * 5, 1),
                      )),
            ),
          ))
        ]),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }

  Future<List<Restroom>> _getSearchedRestrooms(
      String building, String room, String floor) async {
    // Send request to backend and parse response
    // TODO: change this url later
    const String url = "http://127.0.0.1:8000/restrooms/";
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);

    // Build restroom list based on response
    List<Restroom> restrooms = [];
    for (var restroom in responseData) {
      Restroom restroomData = Restroom(
        id: restroom["_id"],
        building: restroom["building"],
        room: restroom["room"],
        floor: restroom["floor"],
        rating: restroom["rating"],
        cleanliness: restroom["cleanliness"],
        internet: restroom["internet"],
        vibe: restroom["vibe"],
      );
      restrooms.add(restroomData);
    }

    return restrooms;
  }
}

/* Define MongoDB models */
class Restroom {
  final String id;
  final String building;
  final String room;
  final int floor;
  final double rating;
  final double cleanliness;
  final double internet;
  final double vibe;

  Restroom(
      {required this.id,
      required this.building,
      required this.room,
      required this.floor,
      required this.rating,
      required this.cleanliness,
      required this.internet,
      required this.vibe});
}

class Rating {
  final String id;
  final String building;
  final String room;
  final double overall_rating;
  final double cleanliness;
  final double internet;
  final double vibe;
  final String review;
  final int upvotes;
  final int downvotes;
  final String by;

  Rating(
      {required this.id,
      required this.building,
      required this.room,
      required this.overall_rating,
      required this.cleanliness,
      required this.internet,
      required this.vibe,
      required this.review,
      required this.upvotes,
      required this.downvotes,
      required this.by});
}

/* Define Bathroom List Items */
class BathroomTileItem extends StatefulWidget {
  final String name;
  final double cleanliness;
  final double internet;
  final double vibe;
  final double rating;
  const BathroomTileItem(
      {super.key,
      required this.name,
      required this.cleanliness,
      required this.internet,
      required this.vibe,
      required this.rating});
  @override
  _BathroomTileItemState createState() => _BathroomTileItemState();
}

class _BathroomTileItemState extends State<BathroomTileItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
          color: Colors.white10,
          // child: const Text("what"),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text("what"),
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
                            widget.name,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Cleanliness: ${widget.cleanliness}',
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Internet: ${widget.internet}',
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Vibe: ${widget.vibe}',
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
                        Text('${widget.rating}',
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
                        children: const [
                          Text('Reviews', style: TextStyle(fontSize: 20)),
                          Icon(Icons.arrow_circle_right_rounded,
                              color: Colors.blue, size: 20)
                        ],
                      ),
                    ),
                  ],
                ))
              ])),
    );
  }
}
