import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/search_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/searches_tiles/RestroomTileItem.dart';
import 'package:tootaloo/ui/models/restroom.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/* Define the screen itself */
class RestroomSearchScreen extends StatefulWidget {
  const RestroomSearchScreen({super.key, required this.title});
  final String title;

  @override
  State<RestroomSearchScreen> createState() => _RestroomSearchScreenState();
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

/* Get list of restrooms the user searches for from the backend */
Future<List<Restroom>> getSearchedRestrooms(
    String building, String room, String floor) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {"building": building, "floor": floor};
  Uri uri =
      Uri.http(dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'), "/restrooms-by-building-and-floor/", queryParams);
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