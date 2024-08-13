/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inten/const/constants.dart';
import 'package:inten/model/choices_class.dart';
import 'package:inten/screen/home/home_screen.dart';
import 'package:inten/screen/info_get/final_setup/final_setup.dart';
import 'package:inten/screen/info_get/personal_info/personal_info.dart';
import 'package:inten/screen/info_get/who_is_it/who_is_it.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class UserInfoMain extends StatefulWidget {
  const UserInfoMain({super.key});

  @override
  State<UserInfoMain> createState() => _UserInfoMainState();
}

class _UserInfoMainState extends State<UserInfoMain> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedChoice;

  List<Widget> _pages = [

  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      WhoIsIt(onChoiceSelected: _onChoiceSelected), // Pass the callback
      PersonalInfo(),
      FinalSetup(),
    ];
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onChoiceSelected(String choice) {
    _selectedChoice = choice; // Store the chosen option
  }

  void _sendChoiceToFirestore(String choice) async {
    User? user = _auth.currentUser;

    final choiceModel = ChoiceModel(
      id: null,
      selectedChoice: choice,
      timestamp: DateTime.now(),
    );

    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(user?.uid)
          .collection('choice')
          .add(choiceModel.toMap());

      // Set the ID after the document has been created
      choiceModel.id = docRef.id;

      print(
          'Sent choice: ${choiceModel.selectedChoice} to Firestore with ID: ${choiceModel.id}');
    } catch (e) {
      // Handle any errors
      print('Error sending choice to Firestore: $e');
    }
  }

  void _onNextPage() {
    if (_currentPage < _pages.length - 1) {
      // If not on the last page, navigate to the next page
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // If on the last page, send the choice to Firestore before navigating
      if (_selectedChoice != null) {
        _sendChoiceToFirestore(_selectedChoice!);
      }

      // Navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }

  Constants myConstants = Constants();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _pages,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SmoothPageIndicator(
                  controller: _pageController, // PageController
                  count: _pages.length, // Total number of pages
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.black,
                    dotHeight: 10,
                    dotWidth: 10,
                    expansionFactor: 5,
                    spacing: 5,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _onNextPage,
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: myConstants.RobotoR,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inten/const/constants.dart';
import 'package:inten/model/choices_class.dart'; // Ensure you have this model defined
import 'package:inten/screen/home/home_screen.dart';
import 'package:inten/screen/info_get/final_setup/final_setup.dart';
import 'package:inten/screen/info_get/personal_info/personal_info.dart';
import 'package:inten/screen/info_get/who_is_it/who_is_it.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class UserInfoMain extends StatefulWidget {
  const UserInfoMain({Key? key}) : super(key: key);

  @override
  State<UserInfoMain> createState() => _UserInfoMainState();
}

class _UserInfoMainState extends State<UserInfoMain> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedChoice;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages = [
      WhoIsIt(onChoiceSelected: _onChoiceSelected), // Pass the user selection callbacks
      PersonalInfo(),
      FinalSetup(),
    ];
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onChoiceSelected(String choice) {
    _selectedChoice = choice; // Store the chosen option for later use
  }

  void _sendChoiceToFirestore(String choice) async {
    User? user = _auth.currentUser;

    final choiceModel = ChoiceModel(
      id: null,
      selectedChoice: choice,
      timestamp: DateTime.now(),
    );

    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(user?.uid)
          .collection('choice')
          .add(choiceModel.toMap());

      // Set the ID after the document has been created
      choiceModel.id = docRef.id;

      print('Sent choice: ${choiceModel.selectedChoice} to Firestore with ID: ${choiceModel.id}');
    } catch (e) {
      print('Error sending choice to Firestore: $e');
    }
  }

  void _onNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // On the last page, save the choice to Firestore before navigating
      if (_selectedChoice != null) {
        _sendChoiceToFirestore(_selectedChoice!);
      }

      // Navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }

  Constants myConstants = Constants();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _pages,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SmoothPageIndicator(
                  controller: _pageController, // PageController
                  count: _pages.length, // Total number of pages
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.black,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
                ElevatedButton(
                  onPressed: _onNextPage,
                  child: Text(_currentPage == _pages.length - 1 ? "Finish" : "Next"),
                ),
              ],
            ),
          ),
          SizedBox(height: 20), // Add some space before the button
        ],
      ),
    );
  }
}