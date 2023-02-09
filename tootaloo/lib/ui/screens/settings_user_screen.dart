import 'package:flutter/material.dart';

import 'package:tootaloo/ui/components/bottom_nav_bar.dart';

class SettingsUserScreen extends StatefulWidget {
  const SettingsUserScreen({super.key, required this.title});
  final String title;

  @override
  State<SettingsUserScreen> createState() => _SettingsUserScreenState();
}

class _SettingsUserScreenState extends State<SettingsUserScreen> {
  final int index = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text("User Settings!"),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: index,
      ),
    );
  }
}
