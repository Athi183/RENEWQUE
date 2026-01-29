import 'package:fashion_ai/screens/assistant_chat.dart';
import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'screens/risk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
      routes: {
        '/': (context) => const WelcomePage(),
        '/risk': (context) => const RiskPage(),
      },
      home: const WelcomePage(),
    );
  }
}
