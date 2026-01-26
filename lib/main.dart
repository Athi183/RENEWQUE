import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Renewque',
      theme: ThemeData(
        fontFamily: 'Manrope',
        scaffoldBackgroundColor: const Color(0xFFF8F7F6),
      ),
      home: const WelcomePage(),
    );
  }
}
