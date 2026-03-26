import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // 🔥 Firebase initialization (THIS WAS MISSING)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        useMaterial3: true,
        fontFamily: 'Manrope',
        scaffoldBackgroundColor: const Color(0xFFF8F7F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF602D08),
          primary: const Color(0xFF602D08),
          onPrimary: Colors.white,
          secondary: const Color(0xFFF3ECE7),
          onSecondary: const Color(0xFF1B130D),
          surface: const Color(0xFFF8F7F6),
        ),
        // Global button themes for consistency
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF602D08),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1B130D),
            side: const BorderSide(color: Color(0xFF602D08)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F7F6),
          foregroundColor: Color(0xFF1B130D),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const WelcomePage(),
    );
  }
}
