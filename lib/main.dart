import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Import halaman splash

void main() {
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinTrack',
      theme: ThemeData(
        primaryColor: const Color(0xFF0C5A3E),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}