import 'dart:convert';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/post_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tootaloo/ui/models/restroom.dart';


double roundDouble(double value, int places){ 
   num mod = pow(10.0, places); 
   return ((value * mod).round().toDouble() / mod); 
}

class PopularRestroomScreen extends StatefulWidget {
  const PopularRestroomScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<PopularRestroomScreen> createState() => _PopularRestroomScreenState();
}

class _PopularRestroomScreenState extends State<PopularRestroomScreen> {
  final int index = 0;

  late List<Restroom> _restrooms;

  @override
  void initState() {
    super.initState();

    _restrooms = [];
    _getRestrooms().then((restrooms) => {
          setState(() {
            for (var restroom in restrooms) {
              _restrooms.add(restroom);
            }
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "PopularRestroom"),
      body: Scaffold(
        appBar: const PostNavBar(title: "bitches", selectedIndex: 2),
        body: Center(
          child: ListView(
            // children: articles.map(_buildArticle).toList(),
            children: _restrooms.map((restroom) => ListTileItem(restroom: restroom)).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: index),
    );
  }
}

Future<List<Restroom>> _getRestrooms() async {
  String url = "http://${dotenv.get('BACKEND_HOSTNAME', fallback: 'BACKEND_HOST not found')}/restrooms/";
  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body);

  List<Restroom> restrooms = [];
  for (var restroom in responseData) {
    Restroom restroomData = Restroom(
        id: "",
        building: restroom["building"],
        room: restroom["room"],
        floor: restroom["floor"],
        rating: restroom["rating"],
        internet: restroom["internet"],
        cleanliness: restroom["cleanliness"],
        vibe: restroom["vibe"],
        privacy: restroom["privacy"]);
    restrooms.add(restroomData);
  }

  return restrooms;
}

class ListTileItem extends StatefulWidget {
  final Restroom restroom;
  const ListTileItem({super.key, required this.restroom});
  @override
  _ListTileItemState createState() => _ListTileItemState();
}

class _ListTileItemState extends State<ListTileItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        color: Colors.white10,
        // child: const Text("what"),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text("what"),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.airline_seat_legroom_extra, size: 40,),
                    Text(widget.restroom.building + widget.restroom.room, style: const TextStyle(fontSize: 40),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Cleanliness: ${roundDouble(widget.restroom.cleanliness, 2)}', style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Internet: ${roundDouble(widget.restroom.internet, 2)}', style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Vibe: ${roundDouble(widget.restroom.vibe, 2)}', style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.only(left: 15), child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Privacy: ${roundDouble(widget.restroom.privacy, 2)}', style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      ],
                    )),
                  ],
                )
                
              ]
            ),
            IntrinsicHeight(child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${roundDouble(widget.restroom.rating, 2)}', style: const TextStyle(fontSize: 30)),
                    const Icon(Icons.star, color: Color.fromARGB(255, 224, 202, 0), size: 30),
                  ],
                ),
                Flexible(
                  flex: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('Reviews', style: TextStyle(fontSize: 20)),
                      Icon(Icons.arrow_circle_right_rounded, color: Colors.blue, size: 20)
                    ],
                  ),
                ), 
              ],
            ))
          ]
        )
      ),
    );
  }
}
