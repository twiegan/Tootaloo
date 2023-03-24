import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';
import 'package:tootaloo/ui/components/logout_button.dart';

class SettingsUserScreen extends StatefulWidget {
  const SettingsUserScreen({super.key, required this.title});
  final String title;

  @override
  State<SettingsUserScreen> createState() => _SettingsUserScreenState();
}

class _SettingsUserScreenState extends State<SettingsUserScreen> {
  final int index = -1;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "User Settings"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'User Settings!',
            ),
            LogoutButton(
              firebaseAuth: firebaseAuth,
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}
