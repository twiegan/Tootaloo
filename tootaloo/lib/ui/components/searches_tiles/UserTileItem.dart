import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserTileItem extends StatefulWidget {
  final String username;
  final bool followed;

  const UserTileItem(
      {super.key, required this.username, required this.followed});
  @override
  _UserTileItemState createState() => _UserTileItemState();
}

class _UserTileItemState extends State<UserTileItem> {
  bool _followed = false;

  @override
  void initState() {
    _followed = widget.followed;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        color: Colors.white10,
        child: ListTile(
          contentPadding: const EdgeInsets.all(5),
          dense: true,
          leading:
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [Icon(Icons.account_circle, size: 40)],
            )
          ]),
          title: Text(
            widget.username,
            style: const TextStyle(fontSize: 20),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                  onPressed: () {
                    // TODO: define currently logged in user here
                    const String loggedInUsername = "ThomasTest";
                    _followed
                        ? unfollowUser(loggedInUsername, widget.username)
                            .then((unfollowed) => {
                                  setState(() {
                                    unfollowed
                                        ? _followed = false
                                        : _followed = true;
                                  })
                                })
                        : followUser(loggedInUsername, widget.username)
                            .then((followed) => {
                                  setState(() {
                                    followed
                                        ? _followed = true
                                        : _followed = false;
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
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> followUser(String followerUsername, String targetUsername) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {
    "followerUsername": followerUsername,
    "targetUsername": targetUsername
  };
  Uri uri = Uri.https(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/follow-user-by-username/",
      queryParams);
  final response = await http.post(uri);
  dynamic responseData = json.decode(response.body);

  return responseData["response"];
}

Future<bool> unfollowUser(
    String followerUsername, String targetUsername) async {
  // Send request to backend and parse response
  // TODO: change this url later
  Map<String, dynamic> queryParams = {
    "followerUsername": followerUsername,
    "targetUsername": targetUsername
  };
  Uri uri = Uri.https(
      dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found'),
      "/unfollow-user-by-username/",
      queryParams);
  final response = await http.post(uri);
  dynamic responseData = json.decode(response.body);

  return responseData["response"];
}
