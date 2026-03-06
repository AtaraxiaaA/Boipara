import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/homepage.dart';

void main() {
  runApp(const BoiparaApp());
}

class BoiparaApp extends StatelessWidget {
  const BoiparaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boipara',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: const Color(0xFF492000),
        scaffoldBackgroundColor: Colors.white,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C2C06),
          primary: const Color(0xFF5C2C06),
          secondary: const Color(0xFF613613),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C2C06),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          border: UnderlineInputBorder(),
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}