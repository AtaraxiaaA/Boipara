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
        useMaterial3: true,
        primaryColor: const Color(0xFF3F51B5),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFFFF8A00),
          surface: Colors.white,
        ),

        // Modern Typography
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          bodyLarge: TextStyle(color: Colors.black87),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8A00),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
          ),
        ),
      ),

      initialRoute: '/home',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
