import 'package:flutter/material.dart';

import 'package:tootaloo/ui/models/rating.dart';
import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/searches_tiles/RatingTileItem.dart';

class RatingsViewScreen extends StatefulWidget {
  const RatingsViewScreen(
      {super.key, required this.title, required this.ratings});

  final String title;
  final List<Rating> ratings;

  @override
  State<RatingsViewScreen> createState() => _RatingsViewScreenState();
}

class _RatingsViewScreenState extends State<RatingsViewScreen> {
  final int index = 0;

  @override
  Widget build(BuildContext context) {
    List<RatingTileItem> ratingTileItems = [];

    for (Rating rating in widget.ratings) {
      RatingTileItem ratingTileItem = RatingTileItem(rating: rating);
      ratingTileItems.add(ratingTileItem);
    }

    return Scaffold(
      appBar: TopNavBar(title: widget.title),
      body: Column(children: [
        ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: ratingTileItems)
      ]),
      bottomNavigationBar: BottomNavBar(selectedIndex: index),
    );
  }
}