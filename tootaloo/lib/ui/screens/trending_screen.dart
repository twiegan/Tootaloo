import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "Trending"),
      body: Container(
        child: Center(
          child: ListView(
            // children: articles.map(_buildArticle).toList(),
            children: List.generate(20, (index) => ListTileItem(
                title: '${faker.randomGenerator.fromCharSet('ABCDEFGHIJKLMONPESTUVWY', 3)}${faker.randomGenerator.integer(999)}', 
                subtitle: '${faker.lorem.sentence()} ${faker.lorem.sentence()}',
              )),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: index),
    );
  }
}

class ListTileItem extends StatefulWidget {
  final String title;
  final String subtitle;
  const ListTileItem({super.key, required this.title, required this.subtitle});
  @override
  _ListTileItemState createState() => _ListTileItemState();
}

class _ListTileItemState extends State<ListTileItem> {
  int _upvotes = 0;
  int _downvotes = 0;
  @override
  Widget build(BuildContext context) {
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
              children: const [
                Icon(Icons.account_circle, size: 40),
                Text("Username")
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
            widget.title,
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Text(widget.subtitle),
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
                  Text('$_upvotes', style: const TextStyle(color: Colors.green),)
                ]
              ),
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
                  Text('$_downvotes', style: const TextStyle(color: Colors.red),)
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}
