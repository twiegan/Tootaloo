import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import 'map_screen.dart';

late List<String> list;
late String imagePath;
late String dropdownValue;
late String buildingId;

class FloorMap extends StatefulWidget {
  const FloorMap({super.key, required this.building});
  final Building building;

  @override
  FloorMapState createState() => FloorMapState();
}

class FloorMapState extends State<FloorMap> {
  @override
  initState() {
    super.initState();
    list = (widget.building.floors).map((item) => item as String).toList();
    dropdownValue = list.first;
    buildingId = widget.building.id;
    imagePath = 'assets/images/floor_maps/$buildingId/$dropdownValue.jpg';
  }

  void callback(String newDropdownValue, String newPath) {
    setState(() {
      dropdownValue = newDropdownValue;
      imagePath = newPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: SizedBox(
              width: MediaQuery.of(context).size.width * 0.80,
              height: 50,
              child: Marquee(
                text: widget.building.name,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
                blankSpace: 30.0,
                velocity: 50.0,
                showFadingOnlyWhenScrolling: true,
                fadingEdgeStartFraction: 0.1,
                fadingEdgeEndFraction: 0.1,
              )),
          backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
          foregroundColor: Colors.black,
        ),
        body: Column(
          children: [
            FittedBox(
              fit: BoxFit.fill,
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.5,
                maxScale: 3,
                child: Image.asset(imagePath,
                    width: 400,
                    height: 600), // TODO: Change image size if necessary
              ),
            ),
            DropdownButtonFloors(callback)
          ],
        ));
  }
}

class DropdownButtonFloors extends StatefulWidget {
  Function callback;
  DropdownButtonFloors(this.callback, {super.key});

  //const DropdownButtonFloors({super.key});

  @override
  State<DropdownButtonFloors> createState() => _DropdownButtonFloorsState();
}

class _DropdownButtonFloorsState extends State<DropdownButtonFloors> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.unfold_more_sharp),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        widget.callback(
            value, 'assets/images/floor_maps/$buildingId/$value.jpg');
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
