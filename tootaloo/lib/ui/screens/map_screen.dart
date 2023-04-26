import 'dart:async';
import 'dart:convert';

import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/filter_dialog.dart';
import 'package:tootaloo/ui/components/map_screen_components.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
// ignore: library_prefixes
import 'package:tootaloo/SharedPref.dart' as sharedPref;
import 'package:tootaloo/ui/models/building.dart';

import 'floor_map_screen.dart';

String URL =
    "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}";

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.title});
  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  //final LatLng _initialcameraposition = const LatLng(40.427715, -86.916992);
  final Location location = Location();

  late double _zoomLevel;
  LocationData _currLocation =
      LocationData.fromMap({'latitude': 40.427715, 'longitude': -86.916992});
  late Map<String, String> _ratingValueMap;
  late List<Building> _buildings;
  late List<MarkerData> _customMarkers;
  late GoogleMapController _controller;

  void _onMapCreated(GoogleMapController mapController) {
    _controller = mapController;

    // set map style as map gets created
    _setMapStyle(mapController);

    // update camera position when user location changes
    location.onLocationChanged.listen((l) {
      setState(() {
        _currLocation = l;
      });
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(l.latitude!, l.longitude!), zoom: _zoomLevel),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _zoomLevel = 14.0;

    // add the custom markers retrieved to _customMarkers
    _ratingValueMap = <String, String>{};
    _customMarkers = [];
    _getBuildingMarkers().then((buildings) {
      setState(() {
        _buildings = buildings;
      });

      for (var building in buildings) {
        // get rating and build marker for each building
        _getSummaryRatingForBuilding(building.id).then((ratingValue) => {
              setState(() {
                _ratingValueMap.addAll({building.id: ratingValue});
                MarkerData data = MarkerData(
                    marker: Marker(
                        markerId: MarkerId(building.id),
                        position: LatLng(building.latitude, building.longitude),
                        infoWindow: InfoWindow(
                            title: building.name,
                            snippet:
                                'There are ${building.restroomCount} restrooms in this building.\n$ratingValue'),
                        onTap: () {
                          // hide currently open snackbar
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          // show the snackbar for the tapped building
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: _customSnackBarContent(building),
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
                    child: _customMarker(building.restroomCount, Colors.black));
                _customMarkers.add(data);
              })
            });
      }
      location.getLocation().then((l) {
        setState(() {
          _currLocation = l;
        });
      });
    });
  }

  final int index = 3;

  callback(newMarkers) {
    // callback function to modify the custom markers list from the diaglog
    setState(() {
      _customMarkers = newMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: const TopNavBar(title: "Map"),
      body: CustomGoogleMapMarkerBuilder(
        customMarkers: _customMarkers,
        builder: (BuildContext context, Set<Marker>? markers) {
          if (markers == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return GoogleMap(
            zoomGesturesEnabled: true,
            initialCameraPosition: CameraPosition(
                target:
                    LatLng(_currLocation.latitude!, _currLocation.longitude!),
                zoom: _zoomLevel), //TODO: change target lat long if needed
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            markers: markers,
            padding: const EdgeInsets.only(bottom: 5),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        childMargin: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.blue,
        label: const Text("Menu"),
        direction: SpeedDialDirection.up,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              child: const Icon(
                Icons.saved_search,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
              label: 'Nearby',
              onTap: () async {
                // clear currently open snackbars
                ScaffoldMessenger.of(context).clearSnackBars();

                // show the snackbar for info
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: customSnackBarInfoContent(
                        "Finding closest restrooms\nmatching your preference.",
                        "(Closer the darker the marker)"),
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

                // get neary by restrooms
                _getNearbyRestrooms();
              }),
          SpeedDialChild(
            child: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue,
            label: 'Filter',
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FilterWidget(
                        callback: callback,
                        buildContext: scaffoldKey.currentContext!);
                  });
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _getNearbyRestrooms() async {
    List<Building> matchingPrefBuildings = _buildings;

    // Get user preference for currently logged in user
    String? userPreference = await sharedPref.UserPreferences.getPreference();

    // Sort the matching buildings by manhattan distance
    matchingPrefBuildings.sort((a, b) => a
        .manhattanDistance(_currLocation)
        .compareTo(b.manhattanDistance(_currLocation)));

    setState(() {
      _customMarkers.clear();
      int counter = 0;
      for (Building building in matchingPrefBuildings) {
        int preferredRestroomCount;

        if (userPreference == "male") {
          preferredRestroomCount = building.maleCount;
        } else if (userPreference == "female") {
          preferredRestroomCount = building.femaleCount;
        } else if (userPreference == "unisex") {
          preferredRestroomCount = building.unisexCount;
        } else {
          preferredRestroomCount = building.restroomCount;
        }

        if (preferredRestroomCount == 0) {
          continue;
        }

        String restroomCountDescription = "";
        if (preferredRestroomCount == 1) {
          restroomCountDescription =
              "There is $preferredRestroomCount restroom";
        } else {
          restroomCountDescription =
              "There are $preferredRestroomCount restrooms";
        }

        MarkerData data = MarkerData(
            marker: Marker(
                markerId: MarkerId(building.id),
                position: LatLng(building.latitude, building.longitude),
                infoWindow: InfoWindow(
                    title: building.name,
                    snippet:
                        '$restroomCountDescription matching your preference in this building.\n${_ratingValueMap[building.id]}'),
                onTap: () {
                  // hide currently open snackbar
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  // show the snackbar for the tapped building
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: _customSnackBarContent(building),
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
            child: _customMarker(preferredRestroomCount,
                Color.fromRGBO(0, 10 + counter * 15, 50 + counter * 20, 0.75)));
        _customMarkers.add(data);
        counter += 1;
      } // end of for loop

      // zoom in to current location
      _zoomLevel = 15.7;

      // move the map to the current position
      // _controller.animateCamera(
      //   CameraUpdate.newCameraPosition(
      //     CameraPosition(
      //         target: LatLng(
      //             _currLocation.latitude!, _currLocation.longitude!),
      //         zoom: _zoomLevel),
      //   ),
      // );
    });
  }

  Future<String> _getSummaryRatingForBuilding(String buildingId) async {
    Uri uri = Uri.parse("$URL/summary_ratings_building");
    uri = uri.replace(query: "building=$buildingId");

    final response = await http.get(uri);
    return response.body;
  }

  Future<List<Building>> _getBuildingMarkers() async {
    // get the building markers from the database/backend
    String url = "$URL/buildings/";
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);

    List<Building> buildings = [];
    for (var building in responseData) {
      try {
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
        buildings.add(buildingData);
      } catch (e) {
        print(e);
      }
    }

    return buildings;
  }

  void _setMapStyle(GoogleMapController mapController) async {
    // set map style to custom style
    final String mapStyle =
        await rootBundle.loadString('assets/text/map_style.txt');
    mapController.setMapStyle(mapStyle);
  }

  Widget _customMarker(int numberOfBathrooms, Color color) {
    return Stack(
      children: [
        Icon(
          Icons.add_location,
          color: color,
          size: 50,
        ),
        Positioned(
          left: 15,
          top: 8,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(numberOfBathrooms.toString())),
          ),
        )
      ],
    );
  }

  Widget _customSnackBarContent(Building building) {
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
              color: Colors.greenAccent, //TODO: change color if favorited
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
}
