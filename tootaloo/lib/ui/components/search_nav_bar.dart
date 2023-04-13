import 'package:flutter/material.dart';

import 'package:tootaloo/ui/screens/searches/restroom_search_screen.dart';
import 'package:tootaloo/ui/screens/searches/user_search_screen.dart';

class SearchNavBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchNavBar(
      {super.key, required this.title, required this.selectedIndex});
  final String title;
  final int selectedIndex;

  @override
  State<SearchNavBar> createState() => _SearchNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _SearchNavBarState extends State<SearchNavBar> {
  int selectedIndex = 0;

  static const List<Widget> _navBarPages = <Widget>[
    RestroomSearchScreen(title: "Restroom Search"),
    UserSearchScreen(title: "User Search"),
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
              icon: Icon(Icons.bathroom), label: "Restroom Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "User Search"),
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
