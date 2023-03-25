import 'dart:async';
import 'dart:convert';

import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

import 'floor_map_screen.dart';

const String URL = 'http://127.0.0.1:8000'; //TODO: change this url later

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.title});
  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class Building {
  final String id;
  final String name;
  final int restroomCount;
  final double latitude;
  final double longitude;
  final List<dynamic> floors;

  Building(
      {required this.id,
      required this.name,
      required this.restroomCount,
      required this.latitude,
      required this.longitude,
      required this.floors});
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _initialcameraposition = const LatLng(40.4237, -86.9212);
  final Location location = Location();

  late List<MarkerData> _customMarkers;
  late GoogleMapController _controller;

  void _onMapCreated(GoogleMapController mapController) {
    _controller = mapController;

    // set map style as map gets created
    _setMapStyle(mapController);

    // update camera position when user location changes
    location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 14),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    // add the custom markers retrieved to _customMarkers
    _customMarkers = [];
    _getBuildingMarkers().then((buildings) {
      for (var building in buildings) {
        // get rating and build marker for each building
        _getSummaryRatingForBuilding(building.id).then((ratingValue) => {
              setState(() {
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
    });
  }

  final int index = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "Map"),
      body: CustomGoogleMapMarkerBuilder(
        customMarkers: _customMarkers,
        builder: (BuildContext context, Set<Marker>? markers) {
          if (markers == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return GoogleMap(
            zoomGesturesEnabled: true,
            initialCameraPosition:
                CameraPosition(target: _initialcameraposition, zoom: 14),
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            markers: markers,
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }

  Future<String> _getSummaryRatingForBuilding(String buildingId) async {
    Uri uri = Uri.parse("$URL/summary_ratings_building");
    uri = uri.replace(query: "building=$buildingId");

    final response = await http.get(uri);
    return response.body;
  }

  Future<List<Building>> _getBuildingMarkers() async {
    // get the building markers from the database/backend
    const String url = "$URL/buildings/";
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
            Text(
              '# of Restrooms: ${building.restroomCount}',
              style: const TextStyle(color: Colors.white, fontSize: 11.0),
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
        //Icon(Icons.navigate_next, color: Colors.white) // This Icon
      ],
    );
  }
}
