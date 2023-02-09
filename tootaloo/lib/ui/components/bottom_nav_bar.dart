import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/trending_screen.dart';
import 'package:tootaloo/ui/screens/review_screen.dart';
import 'package:tootaloo/ui/screens/search_screen.dart';
import 'package:tootaloo/ui/screens/map_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, required this.selectedIndex});
  final int selectedIndex;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  // fields
  static const List<Widget> _navBarPages = <Widget>[
    TrendingScreen(title: "Trending"),
    ReviewScreen(title: "Review"),
    SearchScreen(title: "Search"),
    MapScreen(title: "Map"),
  ];

  // general methods

  void _onItemTapped(int index) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return _navBarPages.elementAt(index);
    }));
  }

  // build method

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trending',
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wc),
          label: 'Review',
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
          backgroundColor: Colors.black,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
          backgroundColor: Colors.black,
        ),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.white,
      onTap: _onItemTapped,
    );
  }
}
