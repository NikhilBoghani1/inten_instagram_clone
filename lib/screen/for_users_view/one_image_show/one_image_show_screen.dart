import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageDetailScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String userImage;
  final String postId;
  final String userName;

  const ImageDetailScreen({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.userImage,
    required this.postId,
    required this.userName, // Add this
  }) : super(key: key);

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool isLiked = false; // Track if the post is liked
  bool isSaved = false; // Track if the post is saved
  int likeCount = 0; // Track the like count

  @override
  void initState() {
    super.initState();
    _fetchPostDetails(); // Retrieve post details on init
    print(
        "Current user name: ${_currentUser?.displayName}"); // Print current user's name
  }

  Future<void> _fetchPostDetails() async {
    try {
      final postSnapshot =
          await _firestore.collection('posts').doc(widget.postId).get();
      final postData = postSnapshot.data();
      if (postData != null) {
        setState(() {
          likeCount = postData['likeCount'] ?? 0; // Initialize like count
        });
      }
    } catch (e) {
      print("Error fetching post details: $e");
    }
  }

// Like Button
/*  Future<void> _toggleLike() async {
    final userId = _currentUser?.uid;
    final userName = _currentUser?.displayName ?? 'Anonymous';
    final timestamp =
        FieldValue.serverTimestamp(); // Current timestamp from server
    if (userId != null) {
      final postRef = _firestore.collection('posts').doc(widget.postId);
      final likeRef = postRef.collection('likes').doc(userId);

      try {
        if (isLiked) {
          await likeRef.delete(); // Remove like
          setState(() {
            isLiked = false;
            likeCount--; // Decrement like count
          });
          await postRef.update({'likeCount': FieldValue.increment(-1)});
        } else {
          await likeRef.set({
            'liked': true,
            'userId': userId,
            'userName': userName, // You can set a default name if necessary
            'timestamp': timestamp,
          }); // Add like with additional info
          setState(() {
            isLiked = true;
            likeCount++; // Increment like count
          });
          await postRef.update({'likeCount': FieldValue.increment(1)});
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling like: $e')),
        );
      }
    }
  }*/
  Future<void> _toggleLike() async {
    final userId = _currentUser?.uid;
    final userName = _currentUser?.displayName ?? 'Anonymous';
    final timestamp =
        FieldValue.serverTimestamp(); // Current timestamp from server
    if (userId != null) {
      final postRef = _firestore.collection('posts').doc(widget.postId);
      final likeRef = postRef.collection('likes').doc(userId);

      try {
        if (isLiked) {
          await likeRef.delete(); // Remove like
          setState(() {
            isLiked = false;
            likeCount--; // Decrement like count
          });
          await postRef.update({'likeCount': FieldValue.increment(-1)});
        } else {
          await likeRef.set({
            'liked': true,
            'userId': userId,
            'userName': userName, // Save userName correctly
            'timestamp': timestamp,
          }); // Add like with additional info
          setState(() {
            isLiked = true;
            likeCount++; // Increment like count
          });
          await postRef.update({'likeCount': FieldValue.increment(1)});
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling like: $e')),
        );
      }
    }
  }

// Save Button
  /*Future<void> _toggleSavePost() async {
    final savedPostRef = _firestore.collection('savedPosts').doc(widget.postId);
    try {
      if (isSaved) {
        await savedPostRef.delete(); // Remove saved post
        setState(() {
          isSaved = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post removed from saved')),
        );
      } else {
        await savedPostRef.set({
          'postId': widget.postId,
          'description': widget.description,
          'imageUrl': widget.imageUrl,
          'userName': widget.userName,
          'profileImage': widget.userImage,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post saved successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling save post: $e')),
      );
    }
  }*/
  Future<void> _toggleSavePost() async {
    final savedPostRef = _firestore.collection('savedPosts').doc(widget.postId);
    final userName = _currentUser?.displayName ?? 'Anonymous';
    try {
      if (isSaved) {
        await savedPostRef.delete(); // Remove saved post
        setState(() {
          isSaved = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post removed from saved')),
        );
      } else {
        await savedPostRef.set({
          'postId': widget.postId,
          'description': widget.description,
          'imageUrl': widget.imageUrl,
          'userName': userName, // Save userName correctly
          'profileImage': widget.userImage,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post saved successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling save post: $e')),
      );
    }
  }

  void _sharePost() {
    final shareContent = '''
Check out this post: "${widget.title}"  
${widget.imageUrl}  
Description: "${widget.description}"  
''';
    // Share.share(shareContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _sharePost, // Share post button
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(widget.imageUrl),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.description, style: TextStyle(fontSize: 16)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined),
                      onPressed: _toggleLike,
                    ),
                    Text('$likeCount'), // Display like count
                  ],
                ),
                IconButton(
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
                  onPressed: _toggleSavePost,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
