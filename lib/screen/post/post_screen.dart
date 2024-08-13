import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inten/model/post_model.dart';
import 'package:inten/ui_helper/ui_helper.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController PostTextController = TextEditingController();
  final TextEditingController postTextController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Initialize current user
  }

  Future<void> _addPost() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String postDescription = postTextController.text.trim();

      if (postDescription.isEmpty) {
        _showErrorDialog("Post description cannot be empty.");
        return;
      }

      // Retrieve user data for name and image
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      String userName = userDoc["Name"] ?? "No Name";
      String profileImage = userDoc["profileImage"] ?? '';
      String imageUrl = '';

      // Upload the selected image to Firebase Storage and get the download URL
      if (selectedImagePath != null) {
        imageUrl = await _uploadImage(selectedImagePath!);
      }

      PostModel newPost = PostModel(
        description: postDescription,
        id: '',
        userId: user.uid,
        userName: userName,
        profileImage: profileImage,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(), // Add the image URL to the post model
      );

      try {
        await _firestore.collection('posts').add(newPost.toMap());
        // _showSuccessDialog();
        _showSuccessSnackbar();
        _clearFields();
      } catch (e) {
        print("Error adding post: $e");
        _showErrorDialog(e.toString());
      }
    } else {
      _showErrorDialog("User not logged in.");
    }
  }

  Future<String> _uploadImage(String imagePath) async {
    File file = File(imagePath);
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('posts/$fileName');
      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  void _clearFields() {
    PostTextController.clear();
  }

  /*void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Post successfully Added!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }*/

  void _showSuccessSnackbar() {
    Get.snackbar(
      'Success', // Title of the Snackbar
      'Post successfully added!', // Message of the Snackbar
      snackPosition: SnackPosition.BOTTOM, // Position of the Snackbar on the screen
      backgroundColor: Colors.green, // Background color for the Snackbar
      colorText: Colors.white, // Text color for the Snackbar
      duration: Duration(seconds: 2), // Duration for which the Snackbar is displayed
      margin: EdgeInsets.all(16), // Margin around the Snackbar
      borderRadius: 10, // Border radius for the Snackbar
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String? selectedImagePath; // To hold the path of the selected image.

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImagePath = image.path; // Set the selected image path.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CupertinoColors.inactiveGray.withOpacity(0.2),
              ),
              height: 66, // Adjusted height for better layout
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection("users")
                    .doc(_currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text("User profile not found"));
                  }

                  // Get the user data
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final imageUrl = userData["profileImage"] ?? '';
                  final userName = userData["Name"] ?? "No Name";

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : AssetImage("assets/images/default_avatar.png")
                                  as ImageProvider,
                        ),
                        SizedBox(width: 10),
                        Text(userName, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Post',
                style: TextStyle(
                  fontFamily: myConstants.RobotoR,
                  fontSize: 19,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: postTextController,
                        maxLines: 7,
                        decoration: InputDecoration(
                          hintText: "Write here . . .",
                          hintStyle: TextStyle(
                            fontFamily: 'Roboto',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      if (selectedImagePath != null) // Show image if selected
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Image.file(
                            File(selectedImagePath!),
                            height: 100, // Adjust as needed
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                  Positioned(
                    top: 10, // Adjust according to your layout
                    right: 20,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _pickImage, // On press, call _pickImage
                          icon: Icon(Icons.image),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            // Handle the attachment button press here
                          },
                          icon: Icon(CupertinoIcons.paperclip),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _addPost();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: CupertinoColors.link.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Post",
                          style: TextStyle(
                            fontFamily: myConstants.RobotoR,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          CupertinoIcons.paperplane,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
