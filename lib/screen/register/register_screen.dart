import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inten/const/constants.dart';
import 'package:inten/screen/home/home_screen.dart';
import 'package:inten/screen/info_get/personal_info/personal_info.dart';
import 'package:inten/service/auth_service.dart';
import 'package:inten/service/profile_service.dart';
import 'package:inten/ui_helper/ui_helper.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onSwitch; // Callback to switch between register and login

  const RegisterScreen({required this.onSwitch, Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  File? _image; // Variable to hold the image file

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update image file
      });
    }
  }

/*  Future<void> _register() async {
    // Attempt to sign up the user
    UserCredential? userCredential;
    try {
      userCredential = await _authService.signUp(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      // Handle registration errors
      Get.snackbar(
        'Registration failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: CupertinoColors.systemRed,
        colorText: Colors.white,
        borderRadius: 8,
        margin: EdgeInsets.all(10),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      );
      return; // Exit the method if registration fails
    }

    // Check if registration was successful
    if (userCredential != null) {
      // Get the user ID from the userCredential
      String userId = userCredential.user!.uid;

      // Proceed to upload the image if it exists
      if (_image != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref =
            FirebaseStorage.instance.ref().child('profile_images/$fileName');

        try {
          // Upload the image file
          UploadTask uploadTask = ref.putFile(_image!);
          TaskSnapshot taskSnapshot = await uploadTask;

          // Get the download URL
          String imageUrl = await taskSnapshot.ref.getDownloadURL();

          // Save user data to Firestore
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'Name': nameController.text,
            'Email': emailController.text,
            'ProfilePicture': imageUrl, // Store image URL
          });

          // Navigate to PersonalInfo
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeScreen()));
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $error')),
          );
        }
      } else {
        // If no image is provided, save user data without it
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'Name': nameController.text,
          'Email': emailController.text,
        });

        // Navigate to PersonalInfo
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => PersonalInfo()));
      }
    }
  }*/
  Future<void> _register() async {
    // Attempt to sign up the user
    UserCredential? userCredential;
    try {
      userCredential = await _authService.signUp(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      // Handle registration errors
      Get.snackbar(
        'Registration failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: CupertinoColors.systemRed,
        colorText: Colors.white,
        borderRadius: 8,
        margin: EdgeInsets.all(10),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      );
      return; // Exit the method if registration fails
    }

    // Check if registration was successful
    if (userCredential != null) {
      // Get the user ID from the userCredential
      String userId = userCredential.user!.uid;

      // Initialize user data map
      Map<String, dynamic> userData = {
        'Name': nameController.text,
        'Email': emailController.text,
      };

      // Proceed to upload the image if it exists
      if (_image != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref =
            FirebaseStorage.instance.ref().child('profile_images/$fileName');

        try {
          // Upload the image file
          UploadTask uploadTask = ref.putFile(_image!);
          TaskSnapshot taskSnapshot = await uploadTask;

          // Get the download URL
          String imageUrl = await taskSnapshot.ref.getDownloadURL();
          userData['profileImage'] = imageUrl; // Store image URL in user data
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $error')),
          );
          return; // Exit if image upload fails
        }
      }

      // Save user data to Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(userData);
        // Navigate to the next screen
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      } catch (error) {
        // Handle Firestore write errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save user data: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Constants myConstants = Constants();

    return Scaffold(
      body: SingleChildScrollView(
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
                    "Sign up",
                    style: TextStyle(
                      fontFamily: myConstants.RobotoM,
                      fontSize: 29,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image(
                            image:
                                AssetImage("assets/images/default_photo.jpg"),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Name',
                style: TextStyle(
                  fontFamily: myConstants.RobotoR,
                  fontSize: 18,
                  color: CupertinoColors.black.withOpacity(0.7),
                ),
              ),
            ),
            SizedBox(height: 8),
            UiHelper.CustomTextField(nameController, "Enter Your Name", false),
            SizedBox(height: 30),
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
            UiHelper.CustomTextField(emailController, "Email", false),
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
            UiHelper.CustomTextField(passwordController, "Password", false),
            SizedBox(height: 30),
            UiHelper.CustomButton(() {
              _register();
            }, "Register"),
            SizedBox(height: 30),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      fontFamily: myConstants.RobotoR,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onSwitch,
                    child: Text(
                      "Log in",
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
    );
  }
}
