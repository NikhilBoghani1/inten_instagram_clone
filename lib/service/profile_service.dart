import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inten/model/personal_info_model.dart'; // Adjust this import as necessary

class Services {
  static final Services _instance = Services._internal();

  factory Services() {
    return _instance;
  }

  Services._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();

  Future<XFile?> pickImage() async {
    try {
      return await _imagePicker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      throw Exception("Failed to pick image: $e");
    }
  }

  Future<String> uploadImage(File image) async {
    if (image == null) {
      throw Exception("No image selected");
    }

    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final uploadRef = storageRef.child('images/$fileName');

      await uploadRef.putFile(image);
      return await uploadRef.getDownloadURL();
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }

  Future<void> uploadProfilePic({
    required File image,
  }) async {
    try {
      // Upload the image and get the URL
      String imageUrl = await uploadImage(image);

      // Create a PersonalInfoModel instance
      PersonalInfoModel personalInfo = PersonalInfoModel(
        image: imageUrl,
        timestamp: DateTime.now(),
      );

      // Save to Firestore in a subcollection 'userInfo'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid) // Get the current user's document
          .collection('userInfo') // Create a subcollection named 'userInfo'
          .add(personalInfo.toMap()); // Add the personal info as a new document
    } catch (e) {
      throw Exception("Failed to submit data: $e");
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

}