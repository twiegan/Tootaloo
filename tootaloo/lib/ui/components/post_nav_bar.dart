import 'package:flutter/material.dart';

import 'package:tootaloo/ui/screens/posts/trending_screen.dart';
import 'package:tootaloo/ui/screens/posts/following_screen.dart';
import 'package:tootaloo/ui/screens/posts/popular_restroom_screen.dart';

class PostNavBar extends StatefulWidget implements PreferredSizeWidget {
  const PostNavBar(
      {super.key, required this.title, required this.selectedIndex});
  final String title;
  final int selectedIndex;

  @override
  State<PostNavBar> createState() => _PostNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _PostNavBarState extends State<PostNavBar> {
  int selectedIndex = 0;

  static const List<Widget> _navBarPages = <Widget>[
    TrendingScreen(title: "Trending"),
    FollowingScreen(title: "Following"),
    PopularRestroomScreen(title: "Popular Restrooms"),
  ];

  void _onItemTapped(int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          return _navBarPages.elementAt(index);
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: "Trending"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Following"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bathroom), label: "Hot Restrooms"),
        ],
        currentIndex: widget.selectedIndex == -1 ? 0 : widget.selectedIndex,
        selectedItemColor: widget.selectedIndex == -1
            ? Colors.white
            : const Color.fromRGBO(48, 157, 247, 1),
        unselectedItemColor: Colors.black,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
      ),
    );
  }
}
