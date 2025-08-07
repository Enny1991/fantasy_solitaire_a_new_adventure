import 'package:flutter/material.dart';

import 'game/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantasy Solitaire: A New Adventure',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SkipLegDay',
      ),
      home: const WelcomeScreen(),
    );
  }
}