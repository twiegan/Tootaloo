import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/AppUser.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/report_user_button.dart';
import 'package:tootaloo/ui/components/search_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/searches_tiles/UserTileItem.dart';
import 'package:tootaloo/ui/models/User.dart';
import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../components/rating_tile.dart';

/* Define the screen itself */
class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key, required this.title});
  final String title;

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

/* Define screen state */
class _UserSearchScreenState extends State<UserSearchScreen> {
  final int index = 2;
  bool _followed = false;
  bool _reported = false;

  late String _selectedUser = "";
  // names map of restrooms we get from API (id: restroom_name)
  late Map<String, String> _userNames = {};
  late User _user = User(
      favorite_restrooms_ids: [],
      username: "",
      posts_ids: [],
      following_ids: [],
      preference: "",
      id: "");
  late List<Rating> _ratings;

  @override
  void initState() {
    super.initState();
    _getUsers().then((users) => {
          setState(() {
            _userNames = users;
          })
        });

    _ratings = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "User Search"),
      body: Scaffold(
        appBar: const SearchNavBar(title: "User Search", selectedIndex: 1),
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
                        items: _userNames.values.toList(),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: "search a user here",
                          ),
                        ),
                        onChanged: (value) async {
                          setState(
                            () {
                              _selectedUser = (value != null) ? value : '';
                            },
                          );
                          bool reported =
                              await _checkReported(_selectedUser, "users");
                          setState(() => _reported = reported);

                          if (_selectedUser == "") return; // Sanity Check
                          AppUser appUser = await UserPreferences.getUser();
                          if (appUser.id == "null") return; // Sanity Check
                          var key = _userNames.keys.firstWhere(
                              (k) => _userNames[k] == _selectedUser,
                              orElse: () => '');
                          if (key != '') {
                            setState(() => _ratings = []);
                            getSearchedUser(key).then((user) => {
                                  checkFollowed(appUser.id, user.id)
                                      .then((followed) => {
                                            setState(() {
                                              _followed = followed;
                                              _user = User(
                                                  id: user.id,
                                                  username: user.username,
                                                  posts_ids: user.posts_ids,
                                                  preference: user.preference,
                                                  following_ids:
                                                      user.following_ids,
                                                  favorite_restrooms_ids: user
                                                      .favorite_restrooms_ids);
                                            })
                                          }),
                                  _getRatings(user).then((ratings) => {
                                        for (var rating in ratings)
                                          {
                                            _userOwned(rating.id)
                                                .then((owned) => {
                                                      setState(() {
                                                        rating.owned = owned;
                                                      })
                                                    }),
                                            setState(() {
                                              _ratings.add(rating);
                                            }),
                                          },
                                        _ratings.sort((a, b) =>
                                            a.downvotes.compareTo(b.downvotes)),
                                        _ratings.sort((b, a) =>
                                            a.upvotes.compareTo(b.upvotes)),
                                      }),
                                });
                          }
                        },
                        selectedItem: _selectedUser))),
            // OutlinedButton.icon(
            //     onPressed: () async {
            //       if (_selectedUser == "") return; // Sanity Check
            //       AppUser appUser = await UserPreferences.getUser();
            //       if (appUser.id == "null") return; // Sanity Check
            //       var key = _userNames.keys.firstWhere(
            //           (k) => _userNames[k] == _selectedUser,
            //           orElse: () => '');
            //       if (key != '') {
            //         setState(() => _ratings = []);
            //         getSearchedUser(key).then((user) => {
            //               checkFollowed(appUser.id, user.id)
            //                   .then((followed) => {
            //                         setState(() {
            //                           _followed = followed;
            //                           _user = User(
            //                               id: user.id,
            //                               username: user.username,
            //                               posts_ids: user.posts_ids,
            //                               preference: user.preference,
            //                               following_ids: user.following_ids,
            //                               favorite_restrooms_ids:
            //                                   user.favorite_restrooms_ids);
            //                         })
            //                       }),
            //               _getRatings(user).then((ratings) => {
            //                     for (var rating in ratings)
            //                       {
            //                         _userOwned(rating.id).then((owned) => {
            //                               setState(() {
            //                                 rating.owned = owned;
            //                               })
            //                             }),
            //                         setState(() {
            //                           _ratings.add(rating);
            //                         }),
            //                       },
            //                     _ratings.sort((a, b) =>
            //                         a.downvotes.compareTo(b.downvotes)),
            //                     _ratings.sort(
            //                         (b, a) => a.upvotes.compareTo(b.upvotes)),
            //                   }),
            //             });
            //       }
            //     },
            //     icon: const Icon(Icons.search),
            //     label: const Text('Search'),
            //     style: OutlinedButton.styleFrom(
            //         foregroundColor: Colors.lightBlue)),
          ]),
          if (_selectedUser != "")
            Row(
              children: [
                Column(children: [
                  _getProfileIcon(_user.preference),
                  Text(_selectedUser,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        OutlinedButton(
                            onPressed: () => {},
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0))),
                                side: MaterialStateProperty.all(
                                    const BorderSide(
                                        color: Colors.black,
                                        width: 1.0,
                                        style: BorderStyle.solid))),
                            child: Text(_user.following_ids.length.toString())),
                        const Text("followers"),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        OutlinedButton(
                            onPressed: () => {},
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0))),
                                side: MaterialStateProperty.all(
                                    const BorderSide(
                                        color: Colors.black,
                                        width: 1.0,
                                        style: BorderStyle.solid))),
                            child: Text(_user.following_ids.length.toString())),
                        const Text("following"),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.all(5),
                    child: OutlinedButton(
                      onPressed: () {
                        getUser().then((appUser) => {
                              _followed
                                  ? unfollowUser(
                                          appUser.username, _selectedUser)
                                      .then((unfollowed) => {
                                            setState(() {
                                              unfollowed
                                                  ? _followed = false
                                                  : _followed = true;
                                            })
                                          })
                                  : followUser(appUser.username, _selectedUser)
                                      .then((followed) => {
                                            setState(() {
                                              followed
                                                  ? _followed = true
                                                  : _followed = false;
                                            })
                                          })
                            });
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: _followed
                              ? const Color.fromARGB(255, 253, 253, 253)
                              : Colors.lightBlue,
                          backgroundColor: _followed
                              ? Colors.lightBlue
                              : const Color.fromARGB(255, 253, 253, 253)),
                      child: _followed
                          ? const Text('Followed')
                          : const Text('Not Followed'),
                    )),
                // Padding(
                //     padding: const EdgeInsets.all(0),
                //     child: IconButton(
                //             onPressed: () => {},
                //             icon: Icon(Icons.flag_outlined, color: Colors.orange,)),

                //     ),
                IconButton(
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(),
                    icon: _reported
                        ? const Icon(Icons.flag, color: Colors.orange)
                        : const Icon(Icons.flag_outlined, color: Colors.orange),
                    onPressed: () {
                      _checkReported(_selectedUser, "users").then((value) {
                        if (!value) {
                          confirmReport(context, _selectedUser);
                        } else {
                          alreadyReported(context);
                        }
                      });
                    }),
              ],
            ),
          Expanded(
              child: ListView(
            // children: articles.map(_buildArticle).toList(),
            children: _ratings
                .map((rating) => RatingTile(
                      rating: rating,
                      screen: "Following",
                    ))
                .toList(),
          )),
        ]),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}

Future<Map<String, String>> _getUsers() async {
  String url =
      "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/users/";
  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body);
  Map<String, String> tempUsers = {};
  for (var user in responseData) {
    tempUsers[user["_id"].values.first] = "${user["username"]}";
  }

  return tempUsers;
}

/* Get User the user searches for from the backend */
Future<User> getSearchedUser(String userId) async {
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

  return userData;
}

Future<bool> checkFollowed(String? followerId, String targetId) async {
  if (followerId == null || followerId == "null") return false; // Sanity check

  // Send request to backend and parse response
  User follower = await getSearchedUser(followerId);

  for (var following_id_map in follower.following_ids) {
    if (following_id_map.values.first == targetId) {
      return true;
    }
  }

  return false;
}

Future<List<Rating>> _getRatings(User user) async {
  String url =
      "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/ratings-by-ids/";
  final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, List<dynamic>>{
        'ids[]': user.posts_ids,
      }));
  if (response.body.toString() == "No user_id") {
    return [];
  }
  var responseData = json.decode(response.body);

  List<Rating> ratings = [];
  for (var rating in responseData) {
    Rating ratingData = Rating(
        id: rating["_id"],
        building: rating["building"],
        by: rating["by"],
        room: rating["room"],
        review: rating["review"],
        overallRating: rating["overall_rating"],
        internet: rating["internet"],
        cleanliness: rating["cleanliness"],
        vibe: rating["vibe"],
        privacy: rating["privacy"],
        upvotes: rating["upvotes"],
        downvotes: rating["downvotes"],
        reports: rating["reports"],
    );
    ratings.add(ratingData);
  }
  return ratings;
}

Future<bool> _userOwned(ratingId) async {
  AppUser user = await UserPreferences.getUser();
  String userId = "";
  if (user.id == null) {
    return true;
  }
  userId = user.id!;
  final response = await http.post(
    Uri.parse(
        'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/post_owned/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'rating_id': ratingId.toString(), 'user_id': userId}),
  );
  if (response.body.toString() == 'false') {
    print("false");
    return false;
  }
  print("true");
  return true;
}

Icon _getProfileIcon(String preference) {
  switch (preference) {
    case "male":
      return const Icon(Icons.man, color: Colors.blue, size: 100);
    case "female":
      return const Icon(Icons.woman, color: Colors.pink, size: 100);
    default:
      return const Icon(Icons.family_restroom, color: Colors.green, size: 100);
  }
}

Future<AppUser> getUser() async {
  return await UserPreferences.getUser();
}

Future<bool> _checkReported(String reportedUsername, String type) async {
  AppUser user = await UserPreferences.getUser();
  String userId = "";
  if (user.id == null) {
    return true;
  }
  userId = user.id!;
  final response = await http.post(
    Uri.parse(
        'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/check-user-reported/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'reported_username': reportedUsername,
      'user_id': userId,
      'type': type
    }),
  );
  if (response.body.toString() == 'false') {
    return false;
  }
  return true;
}

void confirmReport(BuildContext context, reportedUsername) {
  showDialog(
      context: context,
      barrierDismissible:
          false, // disables popup to close if tapped outside popup (need a button to close)
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.flag,
                color: Colors.orange,
              ),
              Text(
                "Confirm Report",
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to report this user?",
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                _updateReports(reportedUsername, "users");
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
                  side: MaterialStateProperty.all(const BorderSide(
                      color: Colors.orange,
                      width: 1.0,
                      style: BorderStyle.solid))),
              child:
                  const Text("Confirm", style: TextStyle(color: Colors.orange)),
              //closes popup
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, //closes popup
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)))),
              child: const Text("Close"),
            ),
          ],
        );
      });
}

void alreadyReported(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible:
          false, // disables popup to close if tapped outside popup (need a button to close)
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.flag,
                color: Colors.orange,
              ),
              Text(
                "Already Reported",
              ),
            ],
          ),
          content: const Text(
            "This user has already been reported by you.",
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, //closes popup
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)))),
              child: const Text("Close"),
            ),
          ],
        );
      });
}

void _updateReports(String reportedUsername, String type) async {
  final response = await http.post(
    Uri.parse(
        'http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/update-user-reports/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'type': type, 'reported_username': reportedUsername}),
  );
}
