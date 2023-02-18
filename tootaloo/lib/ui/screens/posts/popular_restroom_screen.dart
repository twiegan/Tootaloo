import 'dart:math';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/post_nav_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "PopularRestroom"),
      body: Scaffold(
        appBar: const PostNavBar(title: "bitches", selectedIndex: 2),
        body: Center(
          child: ListView(
            // children: articles.map(_buildArticle).toList(),
            children: List.generate(
                20,
                (index) => ListTileItem(
                      title:
                          '${faker.randomGenerator.fromCharSet('ABCDEFGHIJKLMONPESTUVWY', 3)}${faker.randomGenerator.integer(999)}',
                      subtitle:
                          '${faker.lorem.sentence()} ${faker.lorem.sentence()}',
                      cleanliness: roundDouble(faker.randomGenerator.decimal() * 5, 1),
                      internet: roundDouble(faker.randomGenerator.decimal() * 5, 1),
                      vibe: roundDouble(faker.randomGenerator.decimal() * 5, 1),
                      rating: roundDouble(faker.randomGenerator.decimal() * 5, 1),
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
  final double cleanliness;
  final double internet;
  final double vibe;
  final double rating;
  const ListTileItem(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.cleanliness,
      required this.internet,
      required this.vibe,
      required this.rating});
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
                    Text(widget.title, style: const TextStyle(fontSize: 40),),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Cleanliness: ${widget.cleanliness}', style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Internet: ${widget.internet}', style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Vibe: ${widget.vibe}', style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ],
                ),
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
                    Text('${widget.rating}', style: const TextStyle(fontSize: 30)),
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
