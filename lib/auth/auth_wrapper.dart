/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inten/screen/info_get/personal_info/personal_info.dart';
import 'package:inten/screen/login_register/login_register_screen.dart';
import 'package:inten/screen/navigation/navigation_bar.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Stream from Firebase Authentication
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // User is logged in
        if (snapshot.hasData) {
          User user = snapshot.data!;

          // Fetch user's info from the Firestore subcollection
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("userInfo")
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              // Handle potential errors
              if (userSnapshot.hasError) {
                return Center(child: Text('Error fetching user information.'));
              }

              // Check if data exists
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                var userData =
                userSnapshot.data!.data() as Map<String, dynamic>;

                // Check if 'isInfoComplete' exists and is true
                if (userData.containsKey('isInfoComplete') && userData['isInfoComplete'] == true) {
                  // User has filled out their information
                  return NavigationBarView();
                } else {
                  // User has not provided necessary information
                  return PersonalInfo();
                }
              } else {
                // User document doesn't exist, return PersonalInfo
                return PersonalInfo();
              }
            },
          );
        } else {
          // User is not logged in
          return LoginRegisterScreen();
        }
      },
    );
  }
}*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inten/screen/login_register/login_register_screen.dart';
import 'package:inten/screen/navigation/navigation_bar.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return NavigationBarView(); // User is logged in
        } else {
          return LoginRegisterScreen(); // User is not logged in
        }
      },
    );
  }
}
