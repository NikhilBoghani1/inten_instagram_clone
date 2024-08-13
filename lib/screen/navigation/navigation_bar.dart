import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inten/const/constants.dart';
import 'package:inten/screen/home/home_screen.dart';
import 'package:inten/screen/post/post_screen.dart';
import 'package:inten/screen/profile/profile_screen.dart';

class NavigationBarView extends StatefulWidget {
  const NavigationBarView({super.key});

  @override
  State<NavigationBarView> createState() => _NavigationBarViewState();
}

class _NavigationBarViewState extends State<NavigationBarView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  int _currentIndex = 0;

  // Screens for the navigation
  List<Widget> _screens = [
    HomeScreen(),
    // ProfileScreen(),
    // Center(child: Text("Search")),
    PostScreen(),
    Center(child: Text("Notification")),
    ProfileScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Constants myConstants = Constants();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 70,
        // margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          elevation: 0,
          // currentIndex: _selectedIndex,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          items: [
            BottomNavigationBarItem(
              label: 'Home',
              activeIcon: Image.asset(
                color: CupertinoColors.systemIndigo,
                "assets/images/home.png",
                width: 25,
                height: 23,
              ),
              icon: Image.asset(
                "assets/images/home.png",
                width: 25,
                height: 23,
              ),
            ),
            /*BottomNavigationBarItem(
              label: 'Search',
              activeIcon: Image.asset(
                width: 25,
                height: 23,
                color: CupertinoColors.systemIndigo,
                "assets/images/search_icon.png",
              ),
              icon: Image.asset(
                "assets/images/search_icon.png",
                width: 25,
                height: 23,
              ),
            ),*/
            BottomNavigationBarItem(
              label: 'Search',
              activeIcon: Image.asset(
                width: 25,
                height: 23,
                color: CupertinoColors.systemIndigo,
                "assets/images/add.png",
              ),
              icon: Image.asset(
                "assets/images/add.png",
                width: 25,
                height: 23,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              activeIcon: GestureDetector(
                onTap: () {
                  // _showAccountOptions();
                },
                child: Image.asset(
                  width: 25,
                  height: 23,
                  color: CupertinoColors.systemIndigo,
                  "assets/images/bell.png",
                ),
              ),
              icon: Image.asset(
                "assets/images/bell.png",
                width: 25,
                height: 23,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              activeIcon: GestureDetector(
                onTap: () {
                  // _showAccountOptions();
                },
                child: Image.asset(
                  width: 26,
                  height: 25,
                  color: CupertinoColors.systemIndigo,
                  "assets/images/user-edit.png",
                ),
              ),
              icon: Image.asset(
                "assets/images/user-edit.png",
                width: 26,
                height: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
