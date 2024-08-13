import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inten/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBkGuy99HeuTZ5K13ii9fg7GUH1peZsHFk",
      appId: "1:1019147498055:android:4f3dc5c2b4f9c6baea7762",
      messagingSenderId: "1019147498055",
      projectId: "inten-add7a",
      storageBucket: "inten-add7a.appspot.com",
    ),
  );

  String? deviceToken = await FirebaseMessaging.instance.getToken();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inten',
      home: AuthWrapper(),
    );
  }
}
