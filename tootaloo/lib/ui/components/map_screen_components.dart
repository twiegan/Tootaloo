import 'package:flutter/material.dart';

Widget customMarker(int numberOfBathrooms, Color color) {
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

Widget customSnackBarInfoContent(String titleText, String descriptionText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start, //change here don't //worked
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Container(
        margin: const EdgeInsets.only(
            left: 8.0, top: 8.0, bottom: 8.0, right: 25.0),
        width: 24,
        height: 24,
        padding: const EdgeInsets.all(2.0),
        child: const CircularProgressIndicator(
          color: Colors.greenAccent,
          strokeWidth: 3,
        ),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          titleText,
          style: const TextStyle(
              color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        Text(descriptionText,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13.0,
                fontStyle: FontStyle.normal)),
      ]),
    ],
  );
}
