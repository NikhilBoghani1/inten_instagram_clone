/*
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inten/model/personal_info_model.dart'; // Adjust this import as necessary
import 'package:inten/screen/navigation/navigation_bar.dart';
import 'package:inten/ui_helper/ui_helper.dart'; // Make sure you create this UI helper file
import 'package:inten/const/constants.dart'; // Adjust this import to your constants file

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({Key? key}) : super(key: key);

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? _image;
  final ImagePicker _imagePicker = ImagePicker();
  bool isLoading = false;
  String? imageUrl;

  Future<void> pickImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (res != null) {
        setState(() {
          _image = File(res.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<String> uploadImage() async {
    if (_image == null) {
      throw Exception("No image selected");
    }

    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final uploadRef = storageRef.child('images/$fileName');

      await uploadRef.putFile(_image!);
      return await uploadRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> uploadProfilePic() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select an image to upload.")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Upload the image and get the URL
      imageUrl = await uploadImage();

      // Create a PersonalInfoModel instance
      PersonalInfoModel personalInfo = PersonalInfoModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        number: numberController.text.trim(),
        imageUrl: imageUrl,
      );

      // Save to Firestore in a subcollection 'userInfo'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid) // Get the current user's document
          .collection('userInfo') // Create a subcollection named 'userInfo'
          .add(personalInfo.toMap()); // Add the personal info as a new document

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data submitted successfully!")));

      // Optionally clear the form and image
      setState(() {
        nameController.clear();
        emailController.clear();
        numberController.clear();
        _image = null;
      });
    } catch (e) {
      print("Error in uploadProfilePic: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to submit data: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Info"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child:
                      _image == null ? Icon(Icons.camera_alt, size: 50) : null,
                ),
              ),
              SizedBox(height: 20),
              UiHelper.CustomTextField(nameController, "Enter Name", false),
              SizedBox(height: 20),
              UiHelper.CustomTextField(emailController, "Enter Email", false),
              SizedBox(height: 20),
              UiHelper.CustomTextField(numberController, "Enter Number", false),
              SizedBox(height: 60),
              */
/* isLoading
                  ? CircularProgressIndicator()
                  : UiHelper.CustomButton(() {
                uploadProfilePic();
              }, "Submit"),*/ /*

              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true; // Start loading
                        });
                        try {
                          await uploadProfilePic(); // Call your upload function
                          // On success, navigate to the next screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NavigationBarView()),
                          );
                        } catch (e) {
                          // Handle any errors that occur
                          print('Error uploading profile pic: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("Failed to upload profile picture")),
                          );
                        } finally {
                          setState(() {
                            isLoading = false; // Stop loading
                          });
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white, // Customize color if desired
                          strokeWidth: 2, // Adjust stroke width
                        ),
                      )
                    : Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonalInfoModel {
  final String name;
  final String email;
  final String number;
  final String? imageUrl;

  PersonalInfoModel({
    required this.name,
    required this.email,
    required this.number,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'number': number,
      'imageUrl': imageUrl,
    };
  }
}
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inten/screen/navigation/navigation_bar.dart';
import 'package:inten/service/profile_service.dart';
import 'package:inten/ui_helper/ui_helper.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? _image;
  bool isLoading = false;

  Future<void> pickImage() async {
    try {
      XFile? res = await Services().pickImage();
      if (res != null) {
        setState(() {
          _image = File(res.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<void> submitInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        isLoading = true;
      });

      try {
        // Upload profile picture
        if (_image != null) {
          await Services().uploadProfilePic(
            image: _image!,
          );
        }

        // Save additional user info to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          /*'Name': nameController.text,
          'Email': emailController.text,
          'Number': numberController.text,*/
          'isInfoComplete': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data submitted successfully!")));

        // Navigate to the next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationBarView()),
        );
      } catch (e) {
        print("Error saving personal information: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to submit data: $e")));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Info"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                UiHelper.CustomTextField(nameController, "Enter Name", false),
                SizedBox(height: 20),
                UiHelper.CustomTextField(emailController, "Enter Email", false),
                SizedBox(height: 20),
                UiHelper.CustomTextField(
                    numberController, "Enter Number", false),
                SizedBox(height: 60),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await submitInfo(); // Call the submit function
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Submit",
                          style: TextStyle(
                            fontFamily: myConstants.RobotoR,
                            color: Colors.black,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/*
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inten/model/personal_info_model.dart'; // Adjust this import as necessary
import 'package:inten/screen/navigation/navigation_bar.dart';
import 'package:inten/ui_helper/ui_helper.dart'; // Make sure you create this UI helper file
import 'package:inten/const/constants.dart'; // Adjust this import to your constants file

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({Key? key}) : super(key: key);

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? _image;
  final ImagePicker _imagePicker = ImagePicker();
  bool isLoading = false;
  String? imageUrl;

  Future<void> pickImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (res != null) {
        setState(() {
          _image = File(res.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<String> uploadImage() async {
    if (_image == null) {
      throw Exception("No image selected");
    }

    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final uploadRef = storageRef.child('images/$fileName');

      await uploadRef.putFile(_image!);
      return await uploadRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> uploadProfilePic() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select an image to upload.")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Upload the image and get the URL
      imageUrl = await uploadImage();

      // Create a PersonalInfoModel instance
      PersonalInfoModel personalInfo = PersonalInfoModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        number: numberController.text.trim(),
        imageUrl: imageUrl,
      );

      // Save to Firestore in a subcollection 'userInfo'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid) // Get the current user's document
          .collection('userInfo') // Create a subcollection named 'userInfo'
          .add(personalInfo.toMap()); // Add the personal info as a new document

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data submitted successfully!")));

      // Optionally clear the form and image
      setState(() {
        nameController.clear();
        emailController.clear();
        numberController.clear();
        _image = null;
      });
    } catch (e) {
      print("Error in uploadProfilePic: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to submit data: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Info"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child:
                  _image == null ? Icon(Icons.camera_alt, size: 50) : null,
                ),
              ),
              SizedBox(height: 20),
              UiHelper.CustomTextField(nameController, "Enter Name", false),
              SizedBox(height: 20),
              UiHelper.CustomTextField(emailController, "Enter Email", false),
              SizedBox(height: 20),
              UiHelper.CustomTextField(numberController, "Enter Number", false),
              SizedBox(height: 60),
              */
/* isLoading
                  ? CircularProgressIndicator()
                  : UiHelper.CustomButton(() {
                uploadProfilePic();
              }, "Submit"),*/ /*

              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  setState(() {
                    isLoading = true; // Start loading
                  });
                  try {
                    await uploadProfilePic(); // Call your upload function
                    // On success, navigate to the next screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigationBarView()),
                    );
                  } catch (e) {
                    // Handle any errors that occur
                    print('Error uploading profile pic: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text("Failed to upload profile picture")),
                    );
                  } finally {
                    setState(() {
                      isLoading = false; // Stop loading
                    });
                  }
                },
                child: isLoading
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white, // Customize color if desired
                    strokeWidth: 2, // Adjust stroke width
                  ),
                )
                    : Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonalInfoModel {
  final String name;
  final String email;
  final String number;
  final String? imageUrl;

  PersonalInfoModel({
    required this.name,
    required this.email,
    required this.number,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'number': number,
      'imageUrl': imageUrl,
    };
  }
}
Create The Singaltan class and class name will services and All method in this classs*/
