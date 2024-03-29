import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/ui/components/report_user_button.dart';
import 'package:tootaloo/SharedPref.dart';
import 'package:tootaloo/AppUser.dart';

class UserTileItem extends StatefulWidget {
  final String username;
  final bool followed;

  const UserTileItem(
      {super.key, required this.username, required this.followed});
  @override
  _UserTileItemState createState() => _UserTileItemState();
}

class _UserTileItemState extends State<UserTileItem> {
  late Future<AppUser> _appUser;
  bool _followed = false;
  bool initialized = false;

  Future<AppUser> getUser() async {
    return await UserPreferences.getUser();
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) _followed = widget.followed;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
          color: Colors.white10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.08,
                                child: const Icon(Icons.account_circle))
                          ],
                        )
                      ])),
              Padding(
                  padding: EdgeInsets.all(5),
                  child: Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.username,
                          style: const TextStyle(fontSize: 20))
                    ],
                  ))),
              Padding(
                  padding: EdgeInsets.all(5),
                  child: ReportUserButton(
                      type: "users", reportedUsername: widget.username)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                            onPressed: () {
                              getUser().then((appUser) => {
                                    _followed
                                        ? unfollowUser(appUser.username,
                                                widget.username)
                                            .then((unfollowed) => {
                                                  setState(() {
                                                    initialized = true;
                                                    unfollowed
                                                        ? _followed = false
                                                        : _followed = true;
                                                  })
                                                })
                                        : followUser(appUser.username,
                                                widget.username)
                                            .then((followed) => {
                                                  setState(() {
                                                    initialized = true;
                                                    followed
                                                        ? _followed = true
                                                        : _followed = false;
                                                  })
                                                })
                                  });
                            },
                            icon: _followed
                                ? const Icon(Icons.favorite_rounded)
                                : const Icon(Icons.favorite_outline_rounded),
                            label: _followed
                                ? const Text('Followed')
                                : const Text('Not Followed'),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.lightBlue))
                      ])
                ],
              )
            ],
          )),
    );
  }
}

Future<bool> followUser(String? followerUsername, String targetUsername) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {
    "followerUsername": followerUsername,
    "targetUsername": targetUsername
  };
  Uri uri = Uri.http(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/follow-user-by-username/",
      queryParams);
  final response = await http.post(uri);
  dynamic responseData = json.decode(response.body);

  return responseData["response"];
}

Future<bool> unfollowUser(
    String? followerUsername, String targetUsername) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {
    "followerUsername": followerUsername,
    "targetUsername": targetUsername
  };
  Uri uri = Uri.http(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/unfollow-user-by-username/",
      queryParams);
  final response = await http.post(uri);
  dynamic responseData = json.decode(response.body);

  return responseData["response"];
}
