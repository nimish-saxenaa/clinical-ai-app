import 'package:clinical_ai_app/Screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'Screens/home_screen.dart';
import 'Screens/welcome_screen.dart';
import 'app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: WelcomeScreen(),
    );
  }
}








