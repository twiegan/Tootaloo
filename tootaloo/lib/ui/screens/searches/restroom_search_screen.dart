import 'package:flutter/material.dart';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/search_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/screens/search_screen.dart';

/* Define the screen itself */
class RestroomSearchScreen extends StatefulWidget {
  const RestroomSearchScreen({super.key, required this.title});
  final String title;

  @override
  State<RestroomSearchScreen> createState() => _RestroomSearchScreenState();
}

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

/* Define screen state */
class _RestroomSearchScreenState extends State<RestroomSearchScreen> {
  final int index = 0;

  List<RestroomTileItem> _restrooms = [];

  TextEditingController buildingController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController floorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "Restroom Search"),
      body: Scaffold(
        appBar: const SearchNavBar(title: "Restroom Search", selectedIndex: 0),
        body: Column(children: [
          Row(children: [
            Flexible(
                child: TextField(
              controller: buildingController,
              decoration: const InputDecoration(
                  hintText: 'Building',
                  contentPadding: EdgeInsets.all(2.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    borderSide: BorderSide(color: Colors.blue, width: 0.5),
                  )),
            )),
            Flexible(
                child: TextField(
              controller: roomController,
              decoration: const InputDecoration(
                  hintText: 'Room',
                  contentPadding: EdgeInsets.all(2.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    borderSide: BorderSide(color: Colors.blue, width: 0.5),
                  )),
            )),
            Flexible(
                child: TextField(
              controller: floorController,
              decoration: const InputDecoration(
                  hintText: 'Floor',
                  contentPadding: EdgeInsets.all(2.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    borderSide: BorderSide(color: Colors.blue, width: 0.5),
                  )),
            )),
            OutlinedButton.icon(
                onPressed: () {
                  _restrooms = [];
                  _getSearchedRestrooms(buildingController.text,
                          roomController.text, int.parse(floorController.text))
                      .then((restrooms) => {
                            for (var restroom in restrooms)
                              {
                                setState(() {
                                  RestroomTileItem restroomTileItem =
                                      RestroomTileItem(
                                          name:
                                              "${restroom.building}-${restroom.room}-${restroom.floor}",
                                          cleanliness: restroom.cleanliness,
                                          internet: restroom.internet,
                                          vibe: restroom.vibe,
                                          rating: restroom.rating);
                                  _restrooms.add(restroomTileItem);
                                })
                              }
                          });
                },
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.lightBlue)),
          ]),
          Expanded(
              child: Center(
            child: ListView(
                // children: articles.map(_buildArticle).toList(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: _restrooms),
          ))
        ]),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }

  Future<List<Restroom>> _getSearchedRestrooms(
      String building, String room, int floor) async {
    // Send request to backend and parse response
    // TODO: change this url later
    const String url = "http://b6e7-128-210-106-52.ngrok.io/restrooms/";
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);

    // Build restroom list based on response
    List<Restroom> restrooms = [];
    for (var restroom in responseData) {
      Restroom restroomData = Restroom(
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
  final String building;
  final String room;
  final int floor;
  final double rating;
  final double cleanliness;
  final double internet;
  final double vibe;

  Restroom(
      {required this.building,
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

/* Define Restroom List Items */
class RestroomTileItem extends StatefulWidget {
  final String name;
  final double cleanliness;
  final double internet;
  final double vibe;
  final double rating;
  const RestroomTileItem(
      {super.key,
      required this.name,
      required this.cleanliness,
      required this.internet,
      required this.vibe,
      required this.rating});
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
