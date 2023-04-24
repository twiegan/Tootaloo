import 'package:flutter/material.dart';

import '../screens/review_screen.dart';

class FilterWidget extends StatefulWidget {
  const FilterWidget({super.key});

  @override
  State<StatefulWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  bool isHygiene = false;
  bool isChangingStation = false;
  bool isFavorited = false;
  double ratingValue = 0.0;

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
      title: const Text('Filter by'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Transform.scale(
            scale: 1.13,
            child: CheckboxListTile(
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
                title: const Text(
                  "Favorited",
                  style: TextStyle(fontSize: 13),
                ),
                value: isFavorited,
                onChanged: (bool? value) {
                  isFavoritedChecked(value!);
                }),
          ),
          Transform.translate(
              offset: const Offset(13.0, 10.0),
              child: Transform.scale(
                  scale: 1.13,
                  child: const Text(
                    "Average rating greater than:",
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ))),
          Transform.translate(
              offset: const Offset(0, 15.0),
              child: Slider(
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
          onPressed: () async {},
          child: const Text('Submit'),
        )
      ],
    );
  }
}
