import 'dart:convert';

import 'package:marquee/marquee.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/ui/models/building.dart';
import 'package:tootaloo/ui/screens/posts/following_screen.dart';
import 'package:tootaloo/ui/screens/review_screen.dart';
import 'package:tootaloo/ui/screens/floor_map_screen.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:tootaloo/ui/components/map_screen_components.dart';

String URL =
    "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}";

// ignore: must_be_immutable
class FilterWidget extends StatefulWidget {
  FilterWidget({super.key, required this.callback, required this.buildContext});

  BuildContext buildContext;
  Function callback; // callback function to modify _customMarkers

  @override
  State<StatefulWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  bool isUserLoggedIn = false;
  String userId = "";

  bool isHygiene = false;
  bool isChangingStation = false;
  bool isFavorited = false;
  double ratingValue = 0.0;

  @override
  void initState() {
    super.initState();
    _getUser().then((user) {
      if (user.id != null && user.id != 'null') {
        setState(() {
          isUserLoggedIn = true;
          userId = user.id!;
        });
      }
    });
  }

  void isHygieneChecked(bool newValue) => setState(() {
        isHygiene = newValue;
      });
  void isChangingStationChecked(bool newValue) => setState(() {
        isChangingStation = newValue;
      });
  void isFavoritedChecked(bool newValue) => setState(() {
        isFavorited = newValue;
      });

  @override
  build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter restrooms by'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Transform.scale(
            scale: 1.13,
            child: CheckboxListTile(
                activeColor: Colors.blue,
                title: const Text(
                  "Hygiene products",
                  style: TextStyle(fontSize: 13),
                ),
                value: isHygiene,
                onChanged: (bool? value) {
                  isHygieneChecked(value!);
                }),
          ),
          Transform.scale(
            scale: 1.13,
            child: CheckboxListTile(
                activeColor: Colors.blue,
                title: const Text(
                  "Changing stations",
                  style: TextStyle(fontSize: 13),
                ),
                value: isChangingStation,
                onChanged: (bool? value) {
                  isChangingStationChecked(value!);
                }),
          ),
          Transform.scale(
            scale: 1.13,
            child: CheckboxListTile(
                activeColor: Colors.blue,
                title: const Text(
                  "Favorited",
                  style: TextStyle(fontSize: 13),
                ),
                value: isFavorited,
                onChanged: !isUserLoggedIn
                    ? null
                    : (bool? value) {
                        isFavoritedChecked(value!);
                      }),
          ),
          Transform.translate(
              offset: const Offset(11.0, 15.0),
              child: Transform.scale(
                  scale: 1.13,
                  child: const Text(
                    "Rating greater than:",
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ))),
          Transform.translate(
              offset: const Offset(0, 10.0),
              child: Slider(
                activeColor: Colors.blue,
                min: 0.0,
                max: 5.0,
                divisions: 50,
                value: ratingValue,
                label: "${roundDouble(ratingValue, 1)}",
                onChanged: (value) {
                  setState(() {
                    ratingValue = value;
                  });
                },
              ))
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: () {
            // hide alert dialog and filter restrooms
            Navigator.of(context).pop();

            // clear currently open snackbars
            ScaffoldMessenger.of(context).clearSnackBars();

            if (mounted) {
              _filterRestrooms(
                  isChangingStation, isHygiene, isFavorited, ratingValue);
            }
          },
          child: const Text('Submit'),
        )
      ],
    );
  }

  void _filterRestrooms(bool isChangingStation, bool isHygiene,
      bool isFavorited, double ratingValue) async {
    List<dynamic> restroomsToFilter = [];
    if (isFavorited) {
      // get the restrooms that are favorited by the user to filter

      // get the IDs of favorited restrooms for the current user
      Map<String, dynamic> queryParams = {"user_id": userId};
      Uri uri = Uri.http(
          dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
          "/user-by-id/",
          queryParams);
      final response = await http.get(uri);
      dynamic responseData = json.decode(response.body);

      // with the IDs, get the data for each restroom
      dynamic favoriteRestroomIds = responseData['user']['favorite_restrooms'];
      favoriteRestroomIds ??= [];
      for (dynamic restroomId in favoriteRestroomIds) {
        Map<String, dynamic> queryParams = {"restroom_id": restroomId['\$oid']};
        Uri uri = Uri.http(
            dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
            "/restroom-by-id/",
            queryParams);
        final response = await http.get(uri);

        // convert json to contain only the "restroom" objects without the "status" string
        restroomsToFilter.add(json.decode(response.body)['restroom']);
      }
    } else {
      // get all restrooms to filter
      Uri uri = Uri.parse("$URL/restrooms/");
      final response = await http.get(uri);
      restroomsToFilter = json.decode(response.body);
    }

    // now filter based on hygiene products, changing station and rating
    List<dynamic> filteredRestrooms = restroomsToFilter;

    // description for the loading snackbar
    List<String> descriptionList = [];

    if (isHygiene) {
      // filter by hygiene products
      filteredRestrooms = filteredRestrooms
          .where((restroom) => restroom['hygiene-products'] == true)
          .toList();
      // add hygiene to desscription
      descriptionList.add("hygiene");
    }

    if (isChangingStation) {
      // filter by changing station
      filteredRestrooms = filteredRestrooms
          .where((restroom) => restroom['changing-station'] == true)
          .toList();
      // add changing to description
      descriptionList.add("changing");
    }

    if (isFavorited) {
      // add favorited to description
      descriptionList.add("favorited");
    }

    if (ratingValue > 0) {
      // add rating to description
      descriptionList.add("rating");
    }
    // filter by rating
    filteredRestrooms = filteredRestrooms
        .where((restroom) => restroom['rating'] > ratingValue)
        .toList();

    if (descriptionList.isEmpty) {
      // no options chosen for the filter
      return;
    }

    String description = "(${descriptionList.join(", ")})";

    if (filteredRestrooms.isEmpty) {
      // No restroom matched the filter
      // ignore: use_build_context_synchronously
      showPopupMessage(widget.buildContext, const Icon(Icons.info),
          " No Matching restroom", "No restroom matched your filter.");
      return;
    }

    // show the snackbar for info
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(widget.buildContext).showSnackBar(
      SnackBar(
        content: customSnackBarInfoContent(
            "Finding restrooms based on      \nyour filter.", description),
        backgroundColor: Colors.black87,
        duration: const Duration(milliseconds: 2500),
        width: 320.0, // Width of the SnackBar.
        padding: const EdgeInsets.symmetric(
            horizontal: 15.0, // Inner padding for SnackBar content.
            vertical: 10.0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
      ),
    );

    // Group the items by building
    var buildingGroups =
        groupBy(filteredRestrooms, (dynamic item) => item['building']);

    // populate custom markers for the map screen
    List<MarkerData> markers = <MarkerData>[];

    for (var buildingGroup in buildingGroups.entries) {
      try {
        Uri uri = Uri.parse("$URL/building_by_id");
        uri = uri.replace(query: "building=${buildingGroup.key}");

        final response = await http.get(uri);
        var building = jsonDecode(response.body);

        String restroomCountDescription = "";
        if (buildingGroup.value.length == 1) {
          restroomCountDescription =
              "There is ${buildingGroup.value.length} restroom";
        } else {
          restroomCountDescription =
              "There are ${buildingGroup.value.length} restrooms";
        }

        List<dynamic> roomNumbers =
            buildingGroup.value.map((restroom) => restroom["room"]).toList();

        Building buildingData = Building(
          id: building["_id"],
          name: building["name"],
          restroomCount: building["restroomCount"],
          latitude: building["latitude"],
          longitude: building["longitude"],
          floors: building["floors"],
          maleCount: building["maleCount"],
          femaleCount: building["femaleCount"],
          unisexCount: building["unisexCount"],
        );

        MarkerData markerData = MarkerData(
            marker: Marker(
                markerId: MarkerId(buildingData.id),
                position: LatLng(buildingData.latitude, buildingData.longitude),
                infoWindow: InfoWindow(
                    title: buildingData.name,
                    snippet:
                        '$restroomCountDescription matching your filter in this building.\nRoom #: ${roomNumbers.join(', ')}'),
                onTap: () {
                  // hide currently open snackbar
                  ScaffoldMessenger.of(widget.buildContext)
                      .hideCurrentSnackBar();
                  // show the snackbar for the tapped building
                  ScaffoldMessenger.of(widget.buildContext).showSnackBar(
                    SnackBar(
                      content: _customSnackBarContent(
                          buildingData, widget.buildContext),
                      backgroundColor: Colors.black87,
                      duration: const Duration(milliseconds: 5000),
                      width: 320.0, // Width of the SnackBar.
                      padding: const EdgeInsets.symmetric(
                          horizontal:
                              15.0, // Inner padding for SnackBar content.
                          vertical: 10.0),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                    ),
                  );
                }),
            child: customMarker(buildingGroup.value.length, Colors.black));

        // append the marker to display on the map
        markers.add(markerData);
      } catch (e) {
        print(e);
      }
    }

    widget.callback(markers);
  }

  Future<AppUser> _getUser() async {
    //await pause(const Duration(milliseconds: 100));
    return await UserPreferences.getUser();
  }
}

void showPopupMessage(
    BuildContext context, Icon icon, String title, String text) {
  showDialog(
      context: context,
      barrierDismissible:
          false, // disables popup to close if tapped outside popup (need a button to close)
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              icon,
              Text(
                title,
              ),
            ],
          ),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              }, //closes popup
            ),
          ],
        );
      });
}

Widget _customSnackBarContent(Building building, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Container(
        margin: const EdgeInsets.only(
            left: 8.0, top: 8.0, bottom: 8.0, right: 12.0),
        width: 15.0,
        height: 15.0,
        decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(40.0)),
      ), //Dot on the left
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Text(
              "${building.id}: ",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
                width: 150,
                height: 20,
                child: Marquee(
                  text: building.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                  blankSpace: 30.0,
                  velocity: 50.0,
                  showFadingOnlyWhenScrolling: true,
                  fadingEdgeStartFraction: 0.1,
                  fadingEdgeEndFraction: 0.1,
                ))
          ]),
          const Text(
            //'Total # of Restrooms: ${building.restroomCount}',
            'Click right to see the floor maps',
            style: TextStyle(color: Colors.white, fontSize: 11.0),
          )
        ],
      ),
      const Spacer(), // extra spacing
      IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FloorMap(building: building)),
            );
          },
          icon: const Icon(Icons.navigate_next, color: Colors.white)),
    ],
  );
}
