import 'package:flutter/material.dart';
import 'ui/screens/trending_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tootaloo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TrendingScreen(title: 'Trending'),
    );
  }
}
