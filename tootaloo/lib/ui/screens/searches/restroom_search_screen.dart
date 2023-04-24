import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/search_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/searches_tiles/RestroomTileItem.dart';
import 'package:tootaloo/ui/models/restroom.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dropdown_search/dropdown_search.dart';

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
  late String _selectedRestroom = "";
  // names map of restrooms we get from API (id: restroom_name)
  late Map<String, String> _restroomNames = {};
  // restroom tiles built from names
  late List<RestroomTileItem> _restroomTiles = []; 

  @override
  void initState() {
    super.initState();
    _getRestrooms().then((restrooms) => {
          setState(() {
            _restroomNames = restrooms;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "Restroom Search"),
      body: Scaffold(
        appBar: const SearchNavBar(title: "Restroom Search", selectedIndex: 0),
        body: Column(children: [
          Row(children: [
            Flexible(child: 
                Padding(padding: EdgeInsets.all(10), child: 
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                      showSearchBox: true,
                      disabledItemFn: (String s) => s.startsWith('I'),
                    ),
                    items: _restroomNames.values.toList(),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: "search a restroom here",
                      ),
                    ),
                    onChanged: (value) {
                      _selectedRestroom = (value != null) ? value : '';
                    },
                    selectedItem: _selectedRestroom))),
            Padding(padding: EdgeInsets.all(10), child: 
              OutlinedButton.icon(
                onPressed: () {
                  _restroomTiles = [];
                  var key = _restroomNames.keys.firstWhere(
                      (k) => _restroomNames[k] == _selectedRestroom,
                      orElse: () => '');
                  getSearchedRestrooms(key).then((restrooms) => {
                        for (var restroom in restrooms)
                          {
                            setState(() {
                              RestroomTileItem restroomTileItem =
                                  RestroomTileItem(restroom: restroom);
                              _restroomTiles.add(restroomTileItem);
                            })
                          }
                      });
                },
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.lightBlue)),)
          ]),
          Expanded(
              child: Center(
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: _restroomTiles),
          ))
        ]),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}

Future<Map<String, String>> _getRestrooms() async {
  String url =
      "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/restrooms/";
  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body);
  Map<String, String> tempRestrooms = {};
  for (var restroom in responseData) {
    tempRestrooms[restroom["_id"].values.first] = "${restroom["building"]} ${restroom["room"]}";;
  }

  return tempRestrooms;
}

/* Get list of restrooms the user searches for from the backend */
Future<List<Restroom>> getSearchedRestrooms(String restroomId) async {
  // Send request to backend and parse response
  Map<String, dynamic> queryParams = {"restroom_id": restroomId};
  Uri uri = Uri.http(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/restroom-by-id/",
      queryParams);
  final response = await http.get(uri);
  dynamic responseData = json.decode(response.body);

  List<Restroom> restrooms = [];
  if (responseData == null) return restrooms; // Sanity check

  Restroom restroomData = Restroom(
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

  restrooms.add(restroomData);
  return restrooms;
}