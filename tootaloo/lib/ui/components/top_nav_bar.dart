import 'package:flutter/material.dart';
import 'package:tootaloo/ui/screens/settings_user_screen.dart';

class TopNavBar extends StatefulWidget implements PreferredSizeWidget {
  const TopNavBar({super.key, required this.title});
  final String title;

  @override
  State<TopNavBar> createState() => _TopNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _TopNavBarState extends State<TopNavBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      // leading: IconButton(
      //   icon: const Icon(Icons.settings),
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       PageRouteBuilder(
      //         pageBuilder: (BuildContext context, Animation<double> animation1,
      //             Animation<double> animation2) {
      //           return const SettingsUserScreen(title: "App Settings");
      //         },
      //         transitionDuration: Duration.zero,
      //         reverseTransitionDuration: Duration.zero,
      //       ),
      //     );
      //   },
      //   color: Colors.black,
      // ),
      automaticallyImplyLeading: false,
      title: Text(widget.title, style: const TextStyle(color: Colors.black)),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.account_circle_rounded),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (BuildContext context,
                    Animation<double> animation1,
                    Animation<double> animation2) {
                  return const SettingsUserScreen(title: "User Settings");
                },
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          color: Colors.black,
        ),
      ],
      backgroundColor: const Color.fromRGBO(223, 241, 255, 1),
    );
  }
}
