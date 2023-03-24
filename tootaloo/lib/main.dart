import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'ui/screens/posts/trending_screen.dart';
import 'ui/screens/posts/rating_screen.dart';
import 'package:flutter_config/flutter_config.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth auth = FirebaseAuth.instance;
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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('rating'),
        ),
        body: const RatingScreen(title: '',),
      ),
    );
  }
}
