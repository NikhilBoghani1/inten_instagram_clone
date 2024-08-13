import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inten/ui_helper/ui_helper.dart';
import 'package:path/path.dart'; // To use basename function

class EditPostScreen extends StatefulWidget {
  final String postId;
  final String initialDescription;
  final String initialImageUrl;

  EditPostScreen({
    required this.postId,
    required this.initialDescription,
    required this.initialImageUrl,
  });

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _newImageUrl; // To store the new image URL if an image is selected
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.initialDescription;
    _newImageUrl = widget.initialImageUrl;
  }

  Future<void> _savePost() async {
    if (_selectedImage != null) {
      // Upload new image to storage and get the URL
      _newImageUrl = await uploadImageToStorage(_selectedImage!);
    }

    // Update the post in the Firestore
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({
      'description': _descriptionController.text,
      'imageUrl': _newImageUrl, // Update with the new image URL if available
    });

    /*Navigator.of(context).pop();*/
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;

      String fileName = basename(imageFile.path);
      Reference ref = storage.ref().child('uploads/$fileName');

      await ref.putFile(imageFile);
      String downloadURL = await ref.getDownloadURL();

      return downloadURL; // Return the URL of the uploaded image
    } catch (e) {
      print("Error uploading image: $e");
      return ""; // Handle errors appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Edit Post',
          style: TextStyle(
            fontFamily: myConstants.RobotoR,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _savePost,
            child: Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedImage != null)
              Column(
                children: [
                  Image.file(
                    _selectedImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            if (_newImageUrl != null && _selectedImage == null)
              Column(
                children: [
                  Image.network(
                    _newImageUrl!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Post Description'),
              maxLines: null,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Change Image'),
            ),
          ],
        ),
      ),
    );
  }
}
