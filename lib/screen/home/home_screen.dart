import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inten/const/constants.dart';
import 'package:inten/model/post_model.dart';
import 'package:inten/screen/other_user_profile/other_user_profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;


  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Initialize current user
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out successfully.");
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<void> _toggleSavePost(PostModel post) async {
    post.isSaved = !post.isSaved;
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userId = currentUser.uid; // Get the user ID
      final savedPostRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('savedPosts')
          .doc(post.id); // Reference to the specific post document

      try {
        // Check if the post is already saved
        final doc = await savedPostRef.get();
        if (doc.exists) {
          // If it exists, we unsave it
          await savedPostRef.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post removed from saved')),
          );
        } else {
          // If it doesn't exist, we save it
          await savedPostRef.set({
            'postId': post.id,
            'description': post.description,
            'imageUrl': post.imageUrl,
            'userName': post.userName,
            'profileImage': post.profileImage,
            'timestamp': post.timestamp,
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }

  Future<void> _toggleLike(PostModel post) async {
    final userId = _currentUser
        ?.uid; // Assuming _currentUser contains the logged-in user's information
    if (userId != null) {
      // Fetch user information from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName =
          userDoc.data()?['Name'] ?? null; // Ensure you have a 'userName' field

      final postRef = _firestore.collection('posts').doc(post.id);
      final likeRef = postRef
          .collection('likes')
          .doc(userId); // Reference to the user's like

      try {
        final doc = await likeRef.get();
        if (doc.exists) {
          // User has already liked the post, remove the like
          await likeRef.delete();
          await postRef.update({
            'likeCount': FieldValue.increment(-1), // Decrement likes
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Like removed')));
        } else {
          // User hasn't liked the post, so we add the like
          await likeRef.set({
            'userId': userId,
            'userName': userName ?? 'Unknown',
            // Default to 'Unknown' if userName is null
            'timestamp': FieldValue.serverTimestamp(),
            // Store the timestamp
          });
          await postRef.update({
            'likeCount': FieldValue.increment(1), // Increment likes
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Post liked')));

          await sendLikeNotification(post.userId, userId, post.id);

        }
      } catch (e) {
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User not authenticated')));
    }
  }

  Future<void> sendLikeNotification(String ownerId, String userId, String postId) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNotification');
    try {
      await callable.call({
        'token': await getUserDeviceToken(ownerId), // Get the owner's device token
        'title': 'Post Liked!',
        'body': 'User $userId liked your post with ID $postId',
      });
    } catch (error) {
      print('Error sending notification: $error');
    }
  }

  Future<String?> getUserDeviceToken(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final token = userDoc.data()?['deviceToken'];
    print('Device token for user $userId: $token'); // Log the token
    return token;
  }

  void _sharePost() {
    showModalBottomSheet(
      barrierColor: Colors.grey.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Expanded(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10),
                width: 50,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection("users").snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No users available"));
                    }

                    return ListView.builder(
                      // scrollDirection: Axis.vertical,
                      // Set the scroll direction to horizontal
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        /*return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: doc["profileImage"] != null &&
                                        doc["profileImage"].isNotEmpty
                                    ? NetworkImage(doc["profileImage"])
                                    : AssetImage(
                                            'assets/images/default_photo.jpg')
                                        as ImageProvider, // Use an asset image as the default
                              ),
                              SizedBox(height: 5),
                              Text(doc["Name"]),
                            ],
                          ),
                        );*/
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: doc["profileImage"] !=
                                                null &&
                                            doc["profileImage"].isNotEmpty
                                        ? NetworkImage(doc["profileImage"])
                                        : AssetImage(
                                                'assets/images/default_photo.jpg')
                                            as ImageProvider, // Use an asset image as the default
                                  ),
                                  SizedBox(width: 10),
                                  Text("${doc["Name"]}"),
                                  Spacer(),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 35),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      backgroundColor:
                                          CupertinoColors.link.withOpacity(0.7),
                                    ),
                                    onPressed: () {},
                                    child: Text(
                                      "Send",
                                      style: TextStyle(
                                          fontFamily: myConstants.RobotoR,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /*  void _savePost(PostModel post) async {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userId = currentUser.uid; // Get the user ID

      try {
        // Save the post to the user's saved posts collection
        await _firestore.collection('users').doc(userId).collection('savedPosts').doc(post.id).set({
          'postId': post.id,
          'description': post.description,
          'imageUrl': post.imageUrl,
          'userName': post.userName,
          'profileImage': post.profileImage,
          'timestamp': post.timestamp,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving post: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }*/
  Constants myConstants = Constants();

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Center(child: Text("No user is currently logged in."));
    }

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*StreamBuilder<DocumentSnapshot>(
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
                      final imageUrl = userData["ProfilePicture"] ?? '';
                      final userName = userData["Name"] ?? "No Name";
                      final postImage = userData["imageUrl"] ?? "No Image";

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : AssetImage("assets/images/default_avatar.png")
                                    as ImageProvider,
                          ),
                          */ /*SizedBox(width: 10),
                          Text(userName, style: TextStyle(fontSize: 16)),*/ /*
                        ],
                      );
                    },
                  ),*/
                  Text(
                    "Get Dream",
                    style: TextStyle(
                      fontFamily: myConstants.RobotoR,
                      fontSize: 19,
                    ),
                  ),
                  IconButton(
                    onPressed: signOut,
                    icon: Icon(
                      Icons.login,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            /*Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(CupertinoIcons.search),
                  labelText: 'Search',
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),*/
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              height: 80,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No users available"));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    // Set the scroll direction to horizontal
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to the profile details screen and pass user details
                            /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(userId: doc.id),
                              ),
                            );*/
                            Get.to(
                              UserProfileScreen(userId: doc.id),
                              transition: Transition.downToUp,
                            );
                          },
                          child: Column(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: doc["profileImage"] != null &&
                                        doc["profileImage"].isNotEmpty
                                    ? NetworkImage(doc["profileImage"])
                                    : AssetImage(
                                            'assets/images/default_photo.jpg')
                                        as ImageProvider, // Use an asset image as the default
                              ),
                              SizedBox(height: 5),
                              Text(doc["Name"]),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('posts').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No posts available"));
                  }

                  // Create a list of posts from the snapshot data and reverse the order
                  final posts = snapshot.data!.docs
                      .map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>; // Cast the data
                        return PostModel.fromMap(data)
                          ..id = doc.id; // Use fromMap with safe handling
                      })
                      .toList()
                      .reversed
                      .toList(); // Reverse the list to show the latest posts first

                  // Check if there's at least one post to move to index 1
                  if (posts.length > 1) {
                    // Extract the last post
                    final lastPost = posts
                        .removeLast(); // Remove the last post from the list
                    // Insert the last post at index 1
                    posts.insert(1, lastPost);
                  }

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (ctx, index) {
                      final post = posts[index];
                      DateTime postDateTime = post.timestamp.toDate();
                      String timeAgo;

                      // Check if the post was created within the last minute
                      if (DateTime.now().difference(postDateTime).inMinutes <
                          1) {
                        timeAgo =
                            "a moment ago"; // Customize for very recent posts
                      } else {
                        // Use timeago only for posts older than 1 minute
                        timeAgo = timeago.format(postDateTime);
                      }

                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User information
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: post
                                            .profileImage.isNotEmpty
                                        ? NetworkImage(post.profileImage)
                                        : AssetImage(
                                                "assets/images/default_avatar.png")
                                            as ImageProvider,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    post.userName.isNotEmpty
                                        ? post.userName
                                        : "Unknown User",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  /*Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.bookmark),
                                    onPressed: () {
                                      _toggleSavePost(post);
                                    },
                                  ),*/
                                ],
                              ),
                              SizedBox(height: 8),
                              // Post description
                              Text(post.description),
                              SizedBox(height: 8),
                              // Display how long ago the post was created
                              Text(timeAgo),
                              // This will show "a moment ago" or timeago format
                              SizedBox(height: 8),
                              // Conditional rendering of the image
                              if (post.imageUrl.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Image.network(
                                    height: 200,
                                    width: double.infinity,
                                    post.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              SizedBox(height: 8),
                              Divider(),
                              SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => _toggleLike(post),
                                    child: Icon(
                                      CupertinoIcons.heart_fill,
                                      color: post.likeCount > 0
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    post.likeCount.toString(),
                                    style: TextStyle(
                                      fontFamily: myConstants.RobotoR,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Icon(CupertinoIcons.chat_bubble),
                                  SizedBox(width: 15),
                                  GestureDetector(
                                    child: Icon(CupertinoIcons.location),
                                    onTap: _sharePost,
                                  ),
                                  Spacer(),
                                  /*IconButton(
                                    icon: Icon(
                                      CupertinoIcons.bookmark_fill,
                                      // post.isSaved ? Icons.bookmark : Icons.bookmark_border, // Condition to toggle icons
                                    ),
                                    onPressed: () {
                                      _toggleSavePost(post);
                                    },
                                  ),*/
                                  IconButton(
                                    icon: Icon(
                                      post.isSaved
                                          ? Icons.book
                                          : Icons.bookmark_border,
                                      /*color: post.isSaved
                                          ? Colors.blue
                                          : Colors.grey,*/
                                    ),
                                    onPressed: () => _toggleSavePost(post),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}
