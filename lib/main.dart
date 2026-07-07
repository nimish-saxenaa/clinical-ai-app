import 'package:clinical_ai_app/Screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Models/patient_list_model.dart';
import 'Screens/create_account_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/welcome_screen.dart';
import 'Services/navigation_service.dart';
import 'app_theme.dart';

void main() {
  runApp(ChangeNotifierProvider(
  create: (_) => PatientListProvider(),
  child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: WelcomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        WelcomeScreen.routeName: (context) => WelcomeScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        CreateAccountScreen.routeName: (context) => CreateAccountScreen(),
      },
    );
  }
}








