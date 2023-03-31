import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/post_nav_bar.dart';
import 'package:http/http.dart' as http;

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  final int index = 0;

  late List<Rating> _ratings;

  @override
  void initState() {
    super.initState();

    _ratings = [];
    _getRatings().then((ratings) => {
          setState(() {
            for (var rating in ratings) {
              _ratings.add(rating);
            }
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    print("loading");
    return Scaffold(
      appBar: const TopNavBar(title: "Trending"),
      body: Scaffold(
        appBar: const PostNavBar(title: "bitches", selectedIndex: 0),
        body: Center(
          child: ListView(
            // children: articles.map(_buildArticle).toList(),
            children:
                _ratings.map((rating) => ListTileItem(rating: rating)).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: index),
    );
  }
}

class Rating {
  final String building;
  final String by;
  final String room;
  final String review;
  final num overallRating;
  final num internet;
  final num cleanliness;
  final num vibe;
  final int upvotes;
  final int downvotes;

  Rating({
    required this.building,
    required this.by,
    required this.room,
    required this.review,
    required this.overallRating,
    required this.internet,
    required this.cleanliness,
    required this.vibe,
    required this.upvotes,
    required this.downvotes,
  });
}

Future<List<Rating>> _getRatings() async {
  // get the building markers from the database/backend
  // TODO: change this url later
  const String url = "http://10.44.57.40:8000/users/";

  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body);

  List<Rating> ratings = [];
  for (var rating in responseData) {
    Rating ratingData = Rating(
        building: rating["building"],
        by: rating["by"],
        room: rating["room"],
        review: rating["review"],
        overallRating: rating["overall_rating"],
        internet: rating["internet"],
        cleanliness: rating["cleanliness"],
        vibe: rating["vibe"],
        upvotes: rating["upvotes"],
        downvotes: rating["downvotes"]);
    ratings.add(ratingData);
  }

  return ratings;
}

class ListTileItem extends StatefulWidget {
  final Rating rating;
  const ListTileItem({super.key, required this.rating});
  @override
  _ListTileItemState createState() => _ListTileItemState();
}

class _ListTileItemState extends State<ListTileItem> {
  int _upvotes = 0;
  int _downvotes = 0;
  @override
  Widget build(BuildContext context) {
    print("builtTile");
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        color: Colors.white10,
        child: ListTile(
          //visualDensity: const VisualDensity(vertical: 3), // to expand
          contentPadding: const EdgeInsets.all(5),
          dense: true,
          // onTap: () async {
          //   // ignore: deprecated_member_use
          //   if (await canLaunch(e.url)) {
          //     await launch(e.url);
          //   } else {
          //     throw 'Could not launch ${e.url}';
          //   }
          // },
          leading:
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 40),
                Text(widget.rating.by)
              ],
            ),
            Flexible(
              flex: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, color: Color.fromARGB(255, 218, 196, 0)),
                  Icon(Icons.star, color: Color.fromARGB(255, 218, 196, 0)),
                  Icon(Icons.star, color: Color.fromARGB(255, 218, 196, 0)),
                  Icon(Icons.star),
                  Icon(Icons.star),
                ],
              ),
            ),
          ]),
          title: Text(
            widget.rating.building + widget.rating.room,
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Text(widget.rating.review),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_upward, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          _upvotes += 1;
                        });
                      },
                    ),
                    Text(
                      '${widget.rating.upvotes + _upvotes}',
                      style: const TextStyle(color: Colors.green),
                    )
                  ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_downward, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _downvotes += 1;
                        });
                      },
                    ),
                    Text(
                      '${widget.rating.downvotes + _downvotes}',
                      style: const TextStyle(color: Colors.red),
                    )
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
