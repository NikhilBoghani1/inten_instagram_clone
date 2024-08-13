
import 'package:flutter/material.dart';
import 'package:inten/screen/login/login_screen.dart';
import 'package:inten/screen/register/register_screen.dart';

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool showLoginScreen = true;

  void toggleScreens() {
    setState(() {
      showLoginScreen = !showLoginScreen; // Toggle between login and register
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoginScreen
        ? LoginScreen(onSwitch: toggleScreens)
        : RegisterScreen(onSwitch: toggleScreens);
  }
}
