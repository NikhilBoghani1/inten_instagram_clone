import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inten/const/constants.dart';
import 'package:inten/model/choices_class.dart';

class WhoIsIt extends StatefulWidget {
  final Function(String) onChoiceSelected;

  WhoIsIt({required this.onChoiceSelected});

  @override
  State<WhoIsIt> createState() => _WhoIsItState();
}

class _WhoIsItState extends State<WhoIsIt> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedChoiceIndex = -1; // No choice selected initially

  List<String> choices = [
    "Hire",
    "Hiring",
    "Both",
  ];

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

  @override
  Widget build(BuildContext context) {
    Constants myConstants = Constants();

    return Scaffold(
      /*appBar: AppBar(
        centerTitle: true,
        title:  Text(
          'Choose Options',
          style: TextStyle(fontFamily: myConstants.RobotoR),
        ),
      ),*/
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Text(
              'Choose Options',
              style: TextStyle(
                fontFamily: myConstants.RobotoM,
                fontSize: 19
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: choices.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 10,
                    margin: EdgeInsets.symmetric(horizontal: 20,vertical: 11),
                    child: ListTile(
                      title: Text(
                        choices[index],
                        style: TextStyle(
                          fontFamily: myConstants.RobotoR,
                        ),
                      ),
                      trailing: _selectedChoiceIndex == index
                          ? const Icon(Icons.check,
                              color: Colors.green) // Show check icon if selected
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedChoiceIndex =
                              index; // Update selected choice index
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _selectedChoiceIndex == -1
                  ? null // Disable button if no choice is selected
                  : () {
                      // Store the selected choice using the callback
                      String selectedChoice = choices[_selectedChoiceIndex];
                      widget.onChoiceSelected(selectedChoice); // Notify parent
                      _sendChoiceToFirestore(
                          selectedChoice); // Send to Firestore

                      // Optionally, navigate to another screen or show a confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Choice sent: $selectedChoice'),
                        ),
                      );
                    },
              child: const Text('Add'),
            ),
            SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
