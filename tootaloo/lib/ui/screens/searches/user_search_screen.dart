import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/AppUser.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/search_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/searches_tiles/UserTileItem.dart';
import 'package:tootaloo/ui/models/User.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';
import 'package:dropdown_search/dropdown_search.dart';

/* Define the screen itself */
class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key, required this.title});
  final String title;

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

/* Define screen state */
class _UserSearchScreenState extends State<UserSearchScreen> {
  final int index = 0;

  late String _selectedUser = "";
  // names map of restrooms we get from API (id: restroom_name)
  late Map<String, String> _userNames = {};
  // user tiles built from names
  List<UserTileItem> _userTile = [];

  @override
  void initState() {
    super.initState();
    _getUsers().then((users) => {
          setState(() {
            _userNames = users;
          })
        });
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
                        onChanged: (value) {
                          _selectedUser = (value != null) ? value : '';
                        },
                        selectedItem: _selectedUser))),
            OutlinedButton.icon(
                onPressed: () async {
                  if (_selectedUser == "") return; // Sanity Check
                  AppUser appUser = await UserPreferences.getUser();
                  if (appUser.id == "null") return; // Sanity Check
                  var key = _userNames.keys.firstWhere(
                      (k) => _userNames[k] == _selectedUser,
                      orElse: () => '');
                  if (key != '') {
                    getSearchedUser(key).then((user) => {
                          setState(() {
                            UserTileItem userTileItem = UserTileItem(
                              username: user.username,
                              followed: checkFollowed(appUser.id, user),
                            );
                            _userTile = [userTileItem];
                          })
                        });
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.lightBlue)),
          ]),
          Expanded(
              child: Center(
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: _userTile),
          ))
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
      preference: responseData["user"]["bathroom_preference"]);

  return userData;
}

bool checkFollowed(String? followerId, User user) {
  if (followerId == null || followerId == "null") return false; // Sanity check

  for (var following_id_map in user.following_ids) {
    if (following_id_map.containsValue(followerId)) {
      return true;
    }
  }

  return false;

  // Map<String, dynamic> queryParams = {
  //   "followerUsername": follower,
  //   "targetUsername": target
  // };
  // Uri uri = Uri.http(
  //     dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
  //     "/check-following-by-username/",
  //     queryParams);
  // final response = await http.get(uri);
  // dynamic responseData = json.decode(response.body);

  // if (responseData["response"] == "Success") {
  //   return true;
  // } else {
  //   return false;
  // }
}
