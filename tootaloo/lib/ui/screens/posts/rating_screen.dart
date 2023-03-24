import 'package:flutter/material.dart';
import 'dart:math';

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<RatingScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<RatingScreen> {
  int _counter = 0;
  double _cleanliness = 5;
  double _internet = 5;
  double _vibe = 5;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,

            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Restroom: ', style: TextStyle(fontSize: 20)),
              Flexible(
                child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: 'Enter a Restroom',
                ),
              ))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            children: [
              const Text('Cleanliness: ', style: TextStyle(fontSize: 20)),
              Flexible(
                  child: Slider(
                min: 0.0,
                max: 5.0,
                divisions: 50,
                value: _cleanliness,
                label: '${roundDouble(_cleanliness, 1)}',
                onChanged: (value) {
                  setState(() {
                    _cleanliness = value;
                  });
                },
              )),
            ],
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            children: [
              const Text('   Internet   : ', style: TextStyle(fontSize: 20)),
              Flexible(
                child: Slider(
                  min: 0.0,
                  max: 5.0,
                  divisions: 50,
                  value: _internet,
                  label: '${roundDouble(_internet, 1)}',
                  onChanged: (value) {
                    setState(() {
                      _internet = value;
                    });
                  },
                )
              ),
            ],
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            children: [
              const Text('      Vibe      : ',
                  style: TextStyle(fontSize: 20)),
              Flexible(
                  child: Slider(
                min: 0.0,
                max: 5.0,
                divisions: 50,
                value: _vibe,
                label: '${roundDouble(_vibe, 1)}',
                onChanged: (value) {
                  setState(() {
                    _vibe = value;
                  });
                },
              )),
            ],
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            children: [
              Text('Overall Rating: ${roundDouble((_vibe + _internet + _cleanliness) / 3.0, 1)}', style: const TextStyle(fontSize: 20)),
            ],
          )
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: 10,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Write a Review',
            ),
          )
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ElevatedButton(
              onPressed: () {}, child: const Text('     Submit     ')
            )
          )
        )
      ],
    );
  }
}
