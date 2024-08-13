import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inten/const/constants.dart';
import 'package:inten/screen/navigation/navigation_bar.dart';
import 'package:inten/service/auth_service.dart';
import 'package:inten/ui_helper/ui_helper.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSwitch; // Callback to switch between login and register

  const LoginScreen({required this.onSwitch, Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    User? user = await _authService.signInWithEmailAndPassword(
      emailController.text,
      passwordController.text,
    );

    if (user != null) {
      // Login successful, navigate to HomeScreen
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => NavigationBarView()));
    } else {
      Get.snackbar(
        'Login failed',
        'Login failed. Please check your credentials.',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: CupertinoColors.systemRed,
        colorText: Colors.white,
        borderRadius: 8,
        margin: EdgeInsets.all(10),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Constants myConstants = Constants();

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 130),
              Container(
                margin: EdgeInsets.only(left: 25),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        CupertinoIcons.left_chevron,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      "Log in",
                      style: TextStyle(
                        fontFamily: myConstants.RobotoM,
                        fontSize: 29,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Image.asset(
                  width: 100,
                  height: 100,
                  "assets/images/login.png",
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 80),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontFamily: myConstants.RobotoR,
                    fontSize: 18,
                    color: CupertinoColors.black.withOpacity(0.7),
                  ),
                ),
              ),
              SizedBox(height: 8),
              UiHelper.CustomTextField(emailController, "   Email", false),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontFamily: myConstants.RobotoR,
                    fontSize: 18,
                    color: CupertinoColors.black.withOpacity(0.7),
                  ),
                ),
              ),
              SizedBox(height: 8),
              UiHelper.CustomTextField(
                  passwordController, "   Password", false),
              SizedBox(height: 30),
              UiHelper.CustomButton(() {
                _login();
              }, "Login"),
              SizedBox(height: 30),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Don’t have an account?",
                      style: TextStyle(
                        fontFamily: myConstants.RobotoR,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onSwitch,
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: myConstants.PoppinsSB,
                          color: myConstants.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
