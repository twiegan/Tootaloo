import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/search_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/screens/searches/ratings_view_screen.dart';
import 'package:tootaloo/ui/models/restroom.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:tootaloo/ui/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

/* Define the screen itself */
class RestroomSearchScreen extends StatefulWidget {
  const RestroomSearchScreen({super.key, required this.title});
  final String title;

  @override
  State<RestroomSearchScreen> createState() => _RestroomSearchScreenState();
}

/* Define screen state */
class _RestroomSearchScreenState extends State<RestroomSearchScreen> {
  late Future<AppUser> _appUser;
  bool _favorited = false;
  final int index = 2;
  late String _selectedRestroom = "";
  // names map of restrooms we get from API (id: restroom_name)
  late Map<String, String> _restroomNames = {};
  // restroom to display built from names map
  Restroom _restroom = Restroom(
      id: "",
      building: "n/a",
      room: "n/a",
      floor: 0,
      rating: 0.0,
      cleanliness: 0.0,
      internet: 0.0,
      vibe: 0.0,
      privacy: 0.0,
      ratings_ids: []);

  Future<AppUser> getUser() async {
    return await UserPreferences.getUser();
  }

  @override
  void initState() {
    super.initState();
    _getRestrooms().then((restrooms) => {
          setState(() {
            _restroomNames = restrooms;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "Restroom Search"),
      body: Scaffold(
        appBar: const SearchNavBar(title: "Restroom Search", selectedIndex: 0),
        body: Column(children: [
          Row(children: [
            Flexible(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: DropdownSearch<String>(
                        popupProps: PopupProps.menu(
                          showSelectedItems: true,
                          showSearchBox: true,
                          disabledItemFn: (String s) => s.startsWith('I'),
                        ),
                        items: _restroomNames.values.toList(),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: "search a restroom here",
                          ),
                        ),
                        onChanged: (value) {
                          _selectedRestroom = (value != null) ? value : '';
                        },
                        selectedItem: _selectedRestroom))),
            Padding(
              padding: EdgeInsets.all(10),
              child: OutlinedButton.icon(
                  onPressed: () async {
                    //_restroomTiles = [];
                    var key = _restroomNames.keys.firstWhere(
                        (k) => _restroomNames[k] == _selectedRestroom,
                        orElse: () => '');
                    if (key != '') {
                      getUser().then((appUser) => {
                            if (appUser.id != "null")
                              {
                                getSearchedRestrooms(key).then((restrooms) => {
                                      setState(() {
                                        _restroom = restrooms.first;
                                        checkFavorited(
                                                appUser.id, restrooms.first.id)
                                            .then((favorited) => {
                                                  setState(() {
                                                    _favorited = favorited;
                                                  })
                                                });
                                      })
                                    })
                              }
                          });
                    }
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.lightBlue)),
            )
          ]),
          Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(15),
                  child: Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_restroom.building,
                          style: const TextStyle(
                              fontSize: 42, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: _favorited
                              ? const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.red,
                                  size: 40,
                                )
                              : const Icon(Icons.favorite_outline_rounded,
                                  color: Colors.red, size: 40),
                          onPressed: () {
                            if (_restroom.id != "") {
                              getUser().then((appUser) => {
                                    if (appUser.id != "null")
                                      {
                                        _favorited
                                            ? unfavoriteRestroom(
                                                    appUser.id, _restroom.id)
                                                .then((unfavorited) => {
                                                      setState(() {
                                                        unfavorited
                                                            ? _favorited = false
                                                            : _favorited = true;
                                                      })
                                                    })
                                            : favoriteRestroom(
                                                    appUser.id, _restroom.id)
                                                .then((favorited) => {
                                                      setState(() {
                                                        favorited
                                                            ? _favorited = true
                                                            : _favorited =
                                                                false;
                                                      })
                                                    })
                                      }
                                  });
                            }
                          }),
                    ],
                  ))),
              Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text("Room: ${_restroom.room}",
                              style: const TextStyle(fontSize: 22)),
                          Text("Floor: ${_restroom.floor.toString()}",
                              style: const TextStyle(fontSize: 22)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                              "Cleanliness: ${roundDouble(_restroom.cleanliness, 2)}",
                              style: const TextStyle(fontSize: 22)),
                          Text(
                              "Internet: ${roundDouble(_restroom.internet, 2)}",
                              style: const TextStyle(fontSize: 22)),
                          Text("Vibe: ${roundDouble(_restroom.vibe, 2)}",
                              style: const TextStyle(fontSize: 22)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                              "${roundDouble(_restroom.rating, 2)} with ${_restroom.ratings_ids.length} ratings",
                              style: const TextStyle(fontSize: 22)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RatingBarIndicator(
                                  rating: _restroom.rating.toDouble(),
                                  itemCount: 5,
                                  itemSize: 40.0,
                                  itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Color.fromARGB(255, 218, 196, 0),
                                      )),
                              IconButton(
                                  icon: const Icon(
                                      Icons.arrow_circle_right_rounded,
                                      color: Colors.blue,
                                      size: 40),
                                  onPressed: () async {
                                    if (_restroom.id != '') {
                                      getRating(_restroom.ratings_ids
                                              .map((item) =>
                                                  item.values.single as String)
                                              .toList())
                                          .then((ratings) => {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder:
                                                        (BuildContext context,
                                                            Animation<double>
                                                                animation1,
                                                            Animation<double>
                                                                animation2) {
                                                      return RatingsViewScreen(
                                                          title:
                                                              "${_restroom.building}-${_restroom.room} Reviews", id: _restroom.id);
                                                    },
                                                    transitionDuration:
                                                        Duration.zero,
                                                    reverseTransitionDuration:
                                                        Duration.zero,
                                                  ),
                                                )
                                              });
                                    }
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ]),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}

Future<bool> favoriteRestroom(String? userId, String restroomId) async {
  Map<String, dynamic> queryParams = {
    "user_id": userId,
    "restroom_id": restroomId
  };
  Uri uri = Uri.http(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/favorite-restroom/",
      queryParams);
  final response = await http.post(uri);
  dynamic responseData = json.decode(response.body);

  if (responseData["response"] == "success") {
    return true;
  } else {
    return false;
  }
}

Future<bool> unfavoriteRestroom(String? userId, String restroomId) async {
  Map<String, dynamic> queryParams = {
    "user_id": userId,
    "restroom_id": restroomId
  };
  Uri uri = Uri.http(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/unfavorite-restroom/",
      queryParams);
  final response = await http.post(uri);
  dynamic responseData = json.decode(response.body);

  if (responseData["response"] == "success") {
    return true;
  } else {
    return false;
  }
}

Future<bool> checkFavorited(String? userId, String restroomId) async {
  if (userId == null || userId == "null") return false; // Sanity check

  // Send request to backend and parse response
  Map<String, dynamic> queryParams = {"user_id": userId};
  Uri uri = Uri.http(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/user-by-id/",
      queryParams);
  final response = await http.get(uri);
  dynamic responseData = json.decode(response.body);

  // Build User model based on response
  User userData = User(
      id: responseData["user"]["_id"].values.first,
      username: responseData["user"]["username"],
      posts_ids: responseData["user"]["posts"],
      following_ids: responseData["user"]["following"],
      preference: responseData["user"]["bathroom_preference"],
      favorite_restrooms_ids: responseData["user"]["favorite_restrooms"]);

  for (var favorite_restrooms_id_map in userData.favorite_restrooms_ids) {    
    if (favorite_restrooms_id_map.length > 0) {
      if (favorite_restrooms_id_map['\$oid'] == restroomId) {
        return true;
      }
    }
  }

  return false;
}

Future<Map<String, String>> _getRestrooms() async {
  String url =
      "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/restrooms/";
  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body);
  Map<String, String> tempRestrooms = {};
  for (var restroom in responseData) {
    tempRestrooms[restroom["_id"].values.first] =
        "${restroom["building"]} ${restroom["room"]}";
  }

  return tempRestrooms;
}

/* Get list of restrooms the user searches for from the backend */
Future<List<Restroom>> getSearchedRestrooms(String restroomId) async {
  // Send request to backend and parse response
  Map<String, dynamic> queryParams = {"restroom_id": restroomId};
  Uri uri = Uri.http(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/restroom-by-id/",
      queryParams);
  final response = await http.get(uri);
  dynamic responseData = json.decode(response.body);

  List<Restroom> restrooms = [];
  if (responseData == null) return restrooms; // Sanity check

  Restroom restroomData = Restroom(
      id: responseData["restroom"]["_id"].values.first,
      building: responseData["restroom"]["building"],
      room: responseData["restroom"]["room"],
      floor: responseData["restroom"]["floor"],
      rating: responseData["restroom"]["rating"],
      cleanliness: responseData["restroom"]["cleanliness"],
      internet: responseData["restroom"]["internet"],
      vibe: responseData["restroom"]["vibe"],
      privacy: responseData["restroom"]["privacy"],
      ratings_ids: responseData["restroom"]["ratings"]);

  restrooms.add(restroomData);
  return restrooms;
}

/* Get list of ratings the user searches for from the backend */
Future<List<Rating>> getRating(List<String> ids) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {"ids[]": ids};
  Uri uri = Uri.http(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/ratings-by-ids/",
      queryParams);
  final response = await http.get(uri);
  dynamic responseData = json.decode(response.body);

  // Build rating list based on response
  List<Rating> ratings = [];

  for (var rating in responseData) {
    Rating ratingData = Rating(
        id: rating["_id"].values.first,
        building: rating["building"],
        room: rating["room"],
        overallRating: rating["overall_rating"],
        cleanliness: rating["cleanliness"],
        internet: rating["internet"],
        vibe: rating["vibe"],
        privacy: rating["privacy"],
        upvotes: rating["upvotes"],
        downvotes: rating["downvotes"],
        review: rating["review"],
        by: rating["by"],
        owned: false);
    ratings.add(ratingData);
  }

  return ratings;
}
