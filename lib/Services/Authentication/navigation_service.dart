import 'package:flutter/material.dart';

import '../../Screens/Authentication/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void logout() {
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    LoginScreen.routeName,
        (route) => false,
  );
}