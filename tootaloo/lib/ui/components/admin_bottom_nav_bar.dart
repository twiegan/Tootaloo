import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/admin/post_judgement_screen.dart';
import 'package:tootaloo/ui/screens/admin/user_judgement_screen.dart';
import 'package:tootaloo/ui/screens/posts/trending_screen.dart';
import 'package:tootaloo/ui/screens/review_screen.dart';
import 'package:tootaloo/ui/screens/searches/restroom_search_screen.dart';
import 'package:tootaloo/ui/screens/map_screen.dart';

class AdminBottomNavBar extends StatefulWidget {
  const AdminBottomNavBar({super.key, required this.selectedIndex});
  final int selectedIndex;

  @override
  State<AdminBottomNavBar> createState() => _AdminBottomNavBarState();
}

class _AdminBottomNavBarState extends State<AdminBottomNavBar> {
  // fields
  static const List<Widget> _navBarPages = <Widget>[
    UserJudgementScreen(),
    PostJudgementScreen()
  ];

  // general methods

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

  // build method

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_rounded),
          label: 'User Judgement',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wc),
          label: 'Post Judgement',
          backgroundColor: Colors.white,
        ),
      ],
      currentIndex: widget.selectedIndex == -1 ? 0 : widget.selectedIndex,
      selectedItemColor: widget.selectedIndex == -1
          ? Colors.white
          : const Color.fromRGBO(185, 223, 255, 0.844),
      unselectedItemColor: Colors.white,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      onTap: _onItemTapped,
    );
  }
}
