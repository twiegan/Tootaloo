import 'package:flutter/material.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.title});
  final String title;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final int index = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Review"),
      ),
      body: const Center(
        child: Text("Review!"),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}
