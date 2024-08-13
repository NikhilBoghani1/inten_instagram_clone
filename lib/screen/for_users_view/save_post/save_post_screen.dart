import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavePostScreen extends StatefulWidget {
  const SavePostScreen({super.key});

  @override
  State<SavePostScreen> createState() => _SavePostScreenState();
}

class _SavePostScreenState extends State<SavePostScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('savedPosts')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No saved posts found."));
            }

            // Get the list of saved post documents
            final savedPosts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: savedPosts.length,
              itemBuilder: (ctx, index) {
                // Extract post data from the document
                final postData = savedPosts[index].data() as Map<String, dynamic>;
                final String imageUrl = postData['imageUrl'] ?? '';
                final String description = postData['description'] ?? '';
                final String userName = postData['userName'] ?? '';
                final String userProfile = postData['profileImage'] ?? '';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the user's name
                        Row(
                          children: [
                            CircleAvatar(
                              foregroundImage: NetworkImage(userProfile),
                            ),
                            SizedBox(width: 8),
                            Text(
                              userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Display the image
                        imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        )
                            : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: Center(child: Text('No Image')),
                        ),
                        SizedBox(height: 8),
                        // Display the post description
                        Text(
                          description,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}