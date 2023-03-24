import 'package:flutter/material.dart';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/search_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

import 'package:tootaloo/ui/screens/searches/ratings_view_screen.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/models/restroom.dart';

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
                  if (buildingController.text.isEmpty) return; // Sanity Check
                  getSearchedRestrooms(buildingController.text,
                          roomController.text, floorController.text)
                      .then((restrooms) => {
                            for (var restroom in restrooms)
                              {
                                setState(() {
                                  RestroomTileItem restroomTileItem =
                                      RestroomTileItem(restroom: restroom);
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
}

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