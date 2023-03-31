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

  List<UserTileItem> _user = [];
  TextEditingController userController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "User Search"),
      body: Scaffold(
        appBar: const SearchNavBar(title: "User Search", selectedIndex: 1),
        body: Column(children: [
          Row(children: [
            Flexible(
                child: TextField(
              controller: userController,
              decoration: const InputDecoration(
                  hintText: 'Username',
                  contentPadding: EdgeInsets.all(2.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    borderSide: BorderSide(color: Colors.blue, width: 0.5),
                  )),
            )),
            OutlinedButton.icon(
                onPressed: () async {
                  if (userController.text.isEmpty) return; // Sanity Check
                  AppUser appUser = await UserPreferences.getUser();
                  bool followed = await checkFollowed(
                      appUser.username, userController.text);
                  getSearchedUser(userController.text).then((user) => {
                        setState(() {
                          UserTileItem userTileItem = UserTileItem(
                            username: user.username,
                            followed: followed,
                          );
                          _user = [userTileItem];
                        })
                      });
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
                children: _user),
          ))
        ]),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}

/* Get User the user searches for from the backend */
Future<User> getSearchedUser(String username) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {"username": username};
  Uri uri = Uri.https(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/user-by-username/",
      queryParams);
  final response = await http.get(uri);
  dynamic responseData = json.decode(response.body);

  // Build User model based on response
  User userData = User(
      id: responseData["_id"],
      username: responseData["username"],
      posts_ids: responseData["posts"],
      following_ids: responseData["following"]);

  return userData;
}

Future<bool> checkFollowed(String? follower, String target) async {
  if (follower == null) return false; // Sanity check

  Map<String, dynamic> queryParams = {
    "followerUsername": follower,
    "targetUsername": target
  };
  Uri uri = Uri.https(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/check-following-by-username/",
      queryParams);
  final response = await http.get(uri);
  dynamic responseData = json.decode(response.body);

  if (responseData["response"] == "Success") {
    return true;
  } else {
    return false;
  }
}
