import 'package:flutter/material.dart';
import 'ui/screens/posts/trending_screen.dart';
import 'package:flutter_config/flutter_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
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
        primarySwatch: Colors.blueGrey,
      ),
      home: const TrendingScreen(title: 'Trending'),
    );
  }
}