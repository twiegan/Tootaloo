import 'package:flutter/material.dart';

import 'package:tootaloo/ui/models/rating.dart';

/* Define Rating Tile Items */
class RatingTileItem extends StatefulWidget {
  final Rating rating;
  const RatingTileItem({super.key, required this.rating});
  @override
  _RatingTileItemState createState() => _RatingTileItemState();
}

class _RatingTileItemState extends State<RatingTileItem> {
  int _upvotes = 0;
  int _downvotes = 0;
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
            "${widget.rating.building}-${widget.rating.room}",
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
                      '$_upvotes',
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
                      '$_downvotes',
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