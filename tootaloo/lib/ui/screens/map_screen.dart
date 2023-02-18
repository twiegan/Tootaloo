import 'dart:convert';

import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

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

  Building(
      {required this.id,
      required this.name,
      required this.restroomCount,
      required this.latitude,
      required this.longitude});
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
    _getBuildingMarkers().then((buildings) => {
          for (var building in buildings)
            {
              setState(() {
                MarkerData data = MarkerData(
                    marker: Marker(
                        markerId: MarkerId(building.id),
                        position:
                            LatLng(building.latitude, building.longitude)),
                    child: _customMarker(building.restroomCount, Colors.black));
                _customMarkers.add(data);
              })
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

  Future<List<Building>> _getBuildingMarkers() async {
    // get the building markers from the database/backend
    // TODO: change this url later
    const String url = "http://127.0.0.1:8000/buildings/";
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);

    List<Building> buildings = [];
    for (var building in responseData) {
      Building buildingData = Building(
        id: building["_id"],
        name: building["name"],
        restroomCount: building["restroomCount"],
        latitude: building["latitude"],
        longitude: building["longitude"],
      );
      buildings.add(buildingData);
    }

    return buildings;
  }

  void _setMapStyle(GoogleMapController mapController) async {
    // set map style to custom style
    final String mapStyle =
        await rootBundle.loadString('assets/text/map_style.txt');
    mapController.setMapStyle(mapStyle);
  }

  _customMarker(int numberOfBathrooms, Color color) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.add_location),
          color: color,
          onPressed: () => {print("pressed this button$numberOfBathrooms")},
          iconSize: 40,
        ),
        Positioned(
          left: 19.5,
          top: 14,
          child: Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(numberOfBathrooms.toString())),
          ),
        )
      ],
    );
  }
}
