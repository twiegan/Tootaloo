import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/SharedPref.dart';
import '../screens/review_screen.dart';

String URL =
    "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}";

class FilterWidget extends StatefulWidget {
  const FilterWidget({super.key});

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
              offset: const Offset(0, 19.0),
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
          onPressed: () async {
            _filterRestrooms(
                isChangingStation, isHygiene, isFavorited, ratingValue);
          },
          child: const Text('Submit'),
        )
      ],
    );
  }

  void _filterRestrooms(bool isChangingStation, bool isHygiene,
      bool isFavorited, double ratingValue) async {
    print("$isChangingStation, $isHygiene, $isFavorited, $ratingValue");

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
      dynamic favoriteRestroomIds = responseData['user']['favorite_bathrooms'];
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

    if (isChangingStation) {
      // by changing station
      filteredRestrooms = filteredRestrooms
          .where((restroom) => restroom['changing-station'] == true)
          .toList();
    }

    if (isHygiene) {
      //by hygiene products
      filteredRestrooms = filteredRestrooms
          .where((restroom) => restroom['hygiene-products'] == true)
          .toList();
    }

    // by rating
    filteredRestrooms = filteredRestrooms
        .where((restroom) => restroom['rating'] > ratingValue)
        .toList();

    //print(filteredRestrooms);

    List<dynamic> rooms =
        filteredRestrooms.map((restroom) => restroom["room"]).toList();

    print(rooms);
    print("================================================");

    //TODO: update custom markers from map screen
  }

  Future<AppUser> _getUser() async {
    // await pause(const Duration(milliseconds: 700));
    return await UserPreferences.getUser();
  }
}
