import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tootaloo/ui/screens/login_screen.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  String tosText = 'Empty';

  _read() async {
    String fileText;
    fileText = await rootBundle.loadString("assets/text/terms_of_service.txt");
    setState(() {
      tosText = fileText;
    });
  }

  @override
  Widget build(BuildContext context) {
    _read();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25.0, 100.0, 25.0, 50.0),
                scrollDirection: Axis.vertical, //.horizontal
                child: Text(
                  tosText,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }));
                },
                child: const Text("Return to login"))
          ],
        ),
      ),
    );
  }
}
