import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inten/ui_helper/ui_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String currentName;
  final String currentEmail;
  final String? currentProfilePictureUrl;
  final String? currentBio;

  EditProfileScreen({
    required this.userId,
    required this.currentName,
    required this.currentEmail,
    this.currentProfilePictureUrl,
    this.currentBio,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  TextEditingController bioController = TextEditingController();
  String? profilePictureUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    emailController = TextEditingController(text: widget.currentEmail);
    bioController = TextEditingController(text: widget.currentBio ?? "");
    profilePictureUrl = widget.currentProfilePictureUrl;
  }

/*  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Update the user's profile in the 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'Name': nameController.text,
        'Email': emailController.text,
        'profileImage': profilePictureUrl, // Update if necessary
      });

      // Optionally, update the Firebase Auth email
      if (user.email != emailController.text) {
        await user.updateEmail(emailController.text);
      }

      // Update the user's name in all relevant documents
      await updateUserNameInAllDocuments(widget.userId, nameController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      // You can navigate back to the previous screen if needed
      Navigator.pop(context);
    }
  }*/

  // upload profile image
/*  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Update the user's profile in the 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'Name': nameController.text,
        'Email': emailController.text,
        'profileImage': profilePictureUrl, // Update profile image
      });

      // Update the Firebase Auth email if it's changed
      if (user.email != emailController.text) {
        await user.updateEmail(emailController.text);
      }

      // Update the user's name and profile image in all relevant documents
      await updateUserProfileImageInAllDocuments(widget.userId, profilePictureUrl!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      // You can navigate back to the previous screen if needed
      Navigator.pop(context);
    }
  }*/
  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Update the user's profile in the 'users' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'Name': nameController.text,
        'Email': emailController.text,
        'profileImage': profilePictureUrl, // Update profile image
        'Bio' : bioController.text,
      });

      // Update the Firebase Auth email if it's changed
      if (user.email != emailController.text) {
        await user.updateEmail(emailController.text);
      }

      // Update the user's name and profile image in all relevant documents
      await updateUserProfileImageInAllDocuments(
          widget.userId, profilePictureUrl!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      // You can navigate back to the previous screen if needed
      Navigator.pop(context);
    }
  }

  Future<void> updateUserProfileImageInAllDocuments(
      String userId, String newProfileImageUrl) async {
    // Update profile image in posts
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in postsSnapshot.docs) {
      await doc.reference.update({'profileImage': newProfileImageUrl});
    }

    // Update profile image in comments
    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in commentsSnapshot.docs) {
      await doc.reference.update({'profileImage': newProfileImageUrl});
    }
  }

  Future<void> updateUserNameInAllDocuments(
      String userId, String newName) async {
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in postsSnapshot.docs) {
      await doc.reference.update({'userName': newName});
    }

    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in commentsSnapshot.docs) {
      await doc.reference.update({'userName': newName});
    }
  }

//--------------- Image Piker
/*  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload the image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      File imageFile = File(pickedFile.path);
      try {
        await FirebaseStorage.instance.ref('profile_images/$fileName').putFile(imageFile);
        String downloadUrl = await FirebaseStorage.instance.ref('profile_images/$fileName').getDownloadURL();
        setState(() {
          profilePictureUrl = downloadUrl; // Update the profile picture URL
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }*/
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Retrieve the old image URL from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      String? oldImageUrl = userDoc['profileImage'];

      // Delete the old image from Firebase Storage if it exists
      if (oldImageUrl != null) {
        String filePath = oldImageUrl
            .split('%2F')
            .last
            .split('?')
            .first; // Extract the file name
        try {
          await FirebaseStorage.instance
              .ref('profile_images/$filePath')
              .delete();
        } catch (e) {
          print('Error deleting old image: $e');
        }
      }

      // Upload the new image to Firebase Storage
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      File imageFile = File(pickedFile.path);
      try {
        await FirebaseStorage.instance
            .ref('profile_images/$fileName')
            .putFile(imageFile);
        String downloadUrl = await FirebaseStorage.instance
            .ref('profile_images/$fileName')
            .getDownloadURL();
        setState(() {
          profilePictureUrl = downloadUrl; // Update the profile picture URL
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: myConstants.RobotoR,
          ),
        ),
      ),
      body: Column(
        children: [
          if (profilePictureUrl != null)
            GestureDetector(
              onTap: pickImage, // Allow tapping to change image
              child: CircleAvatar(
                backgroundImage: NetworkImage(profilePictureUrl!),
                radius: 50,
              ),
            )
          else
            GestureDetector(
              onTap: pickImage, // Allow tapping to change image
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 50,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          SizedBox(height: 20),
          UiHelper.CustomTextField(nameController, "Name", false),
          SizedBox(height: 15),
          UiHelper.CustomTextField(emailController, "Email", false),
          SizedBox(height: 15),
          UiHelper.CustomTextField(bioController, "Bio", false),
          SizedBox(height: 20),
          UiHelper.CustomButton(updateProfile, "Update"),
        ],
      ),
    );
  }
}
