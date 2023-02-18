import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.title});
  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  final LatLng _initialcameraposition = const LatLng(40.4237, -86.9212);
  final Location location = Location();
  late List<MarkerData> _customMarkers;
  late GoogleMapController _controller;

  void _onMapCreated(GoogleMapController mapController) {
    _controller = mapController;

    //set map style as map gets created
    _setMapStyle(mapController);

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
    _customMarkers = [
      MarkerData(
          marker:
              Marker(markerId: const MarkerId('id-1'), position: locations[0]),
          child: _customMarker('3', Colors.black)),
      MarkerData(
          marker:
              Marker(markerId: const MarkerId('id-5'), position: locations[4]),
          child: _customMarker('3', Colors.black)),
      MarkerData(
          marker:
              Marker(markerId: const MarkerId('id-2'), position: locations[1]),
          child: _customMarker('4', Colors.black)),
      MarkerData(
          marker:
              Marker(markerId: const MarkerId('id-3'), position: locations[2]),
          child: _customMarker('3', Colors.black)),
      MarkerData(
          marker:
              Marker(markerId: const MarkerId('id-4'), position: locations[3]),
          child: _customMarker('2', Colors.black)),
      MarkerData(
          marker:
              Marker(markerId: const MarkerId('id-5'), position: locations[4]),
          child: _customMarker('1', Colors.black)),
    ];
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

  _customMarker(String numberOfBathrooms, Color color) {
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
            child: Center(child: Text(numberOfBathrooms)),
          ),
        )
      ],
    );
  }

  void _setMapStyle(GoogleMapController mapController) async {
    // set map style to custom style
    final String mapStyle =
        await rootBundle.loadString('assets/text/map_style.txt');
    mapController.setMapStyle(mapStyle);
  }
}
