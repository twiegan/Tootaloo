import 'dart:convert';

import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

// const String mapStyle = '''
//     [
//         {
//             "featureType": "all",
//             "elementType": "all",
//             "stylers": [
//                 {
//                     "invert_lightness": true
//                 },
//                 {
//                     "saturation": 10
//                 },
//                 {
//                     "lightness": 30
//                 },
//                 {
//                     "gamma": 0.5
//                 },
//                 {
//                     "hue": "#435158"
//                 }
//             ]
//         }
//     ]
// ''';

const String mapStyle = '''
[
    {
        "featureType": "all",
        "elementType": "labels.text.fill",
        "stylers": [
            {
                "color": "#7c93a3"
            },
            {
                "lightness": "-10"
            }
        ]
    },
    {
        "featureType": "administrative.country",
        "elementType": "geometry",
        "stylers": [
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "administrative.country",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "color": "#a0a4a5"
            }
        ]
    },
    {
        "featureType": "administrative.province",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "color": "#62838e"
            }
        ]
    },
    {
        "featureType": "landscape",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#dff0ff"
            }
        ]
    },
    {
        "featureType": "landscape.man_made",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#b0bec1"
            },
            {
                "weight": "0.30"
            }
        ]
    },
    {
        "featureType": "poi",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "simplified"
            }
        ]
    },
    {
        "featureType": "poi.attraction",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "poi.business",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "poi.government",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "poi.park",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "poi.place_of_worship",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "poi.school",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "poi.sports_complex",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "all",
        "stylers": [
            {
                "saturation": "-100"
            },
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#bbcacf"
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "lightness": "0"
            },
            {
                "color": "#bbcacf"
            },
            {
                "weight": "0.50"
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "labels",
        "stylers": [
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "labels.text",
        "stylers": [
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#ffffff"
            }
        ]
    },
    {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "color": "#a9b4b8"
            }
        ]
    },
    {
        "featureType": "road.arterial",
        "elementType": "labels.icon",
        "stylers": [
            {
                "invert_lightness": true
            },
            {
                "saturation": "-7"
            },
            {
                "lightness": "3"
            },
            {
                "gamma": "1.80"
            },
            {
                "weight": "0.01"
            }
        ]
    },
    {
        "featureType": "transit",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "water",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#a3c7df"
            }
        ]
    }
]
''';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.title});
  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final locations = const [
    LatLng(40.42771513062505, -86.9169921726821), // lawson
    LatLng(40.427357, -86.913241), // walc
    LatLng(40.424980, -86.911319), // pmu
    LatLng(40.426761, -86.916354), // haas
    LatLng(40.423743, -86.910900), // krannert
  ];

  late List<MarkerData> _customMarkers;

  final LatLng initialcameraposition = const LatLng(40.4237, -86.9212);
  late GoogleMapController controller;
  Location location = Location();

  void _onMapCreated(GoogleMapController ctlr) {
    controller = ctlr;
    controller.setMapStyle(mapStyle);
    location.onLocationChanged.listen((l) {
      controller.animateCamera(
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
        //screenshotDelay: const Duration(seconds: 4),
        customMarkers: _customMarkers,
        builder: (BuildContext context, Set<Marker>? markers) {
          if (markers == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return GoogleMap(
            zoomGesturesEnabled: true,
            initialCameraPosition:
                CameraPosition(target: initialcameraposition, zoom: 14),
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
          //shadows: <Shadow>[Shadow(color: color, blurRadius: 15.0)]
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

  _customMarker2(String symbol, Color color) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: color, blurRadius: 6)]),
      child: Center(child: Text(symbol)),
    );
  }

  _customMarker3(String text, Color color) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: color, blurRadius: 6)]),
      child: Center(
          child: Text(
        text,
        textAlign: TextAlign.center,
      )),
    );
  }
}
