import 'package:flutter/material.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';
import 'package:tootaloo/ui/components/top_nav_bar.dart';

class SettingsAppScreen extends StatefulWidget {
  const SettingsAppScreen({super.key, required this.title});
  final String title;

  @override
  State<SettingsAppScreen> createState() => _SettingsAppScreenState();
}

class _SettingsAppScreenState extends State<SettingsAppScreen> {
  final int index = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(title: "App Settings"),
      body: const Center(
        child: Text("App Settings!"),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}
