import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:inten/const/constants.dart';
import 'package:inten/model/followers_model.dart';
import 'package:inten/model/post_model.dart';
import 'package:inten/screen/list_of_follower.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Constants myConstants = Constants();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;
  bool isFollowing = false;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;

    if (currentUser != null) {
      _checkIfFollowing();
      _loadUserData();
    } else {
      print("Current user is null.");
    }
  }

  Future<void> _checkIfFollowing() async {
    ValueNotifier<bool> isFollowing = ValueNotifier(false);
    // Retrieve follower document and check if following the user
    DocumentSnapshot followerDoc =
        await _firestore.collection('followers').doc(currentUser?.uid).get();

    if (followerDoc.exists) {
      List followingList = followerDoc['following'] ?? [];
      isFollowing.value = followingList.contains(widget.userId);
    }
  }

  Future<void> _loadUserData() async {
    // Load user data to display in the profile
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(widget.userId).get();
    if (userDoc.exists) {
      userData = userDoc.data() as Map<String, dynamic>;
    }
  }

  Future<void> _toggleFollow() async {
    ValueNotifier<bool> isFollowing = ValueNotifier(false);
    if (isFollowing.value) {
      await _removeFollower();
    } else {
      await _addFollower();
    }
    isFollowing.value = !isFollowing.value;
  }

  Future<void> _addFollower() async {
    User? user = _auth.currentUser;

    if (user == null) {
      // Fix here
      print("Current user is null");
      return; // Ensure the current user is not null
    }

    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get(); // Use user.uid directly
    String userName = userDoc["Name"] ?? "No Name";
    String profileImage = userDoc["profileImage"] ?? '';

    // Create a UserModel instance
    final userModel = UserModel(
      userId: user.uid, // Fix here
      userName: userName,
      userProfile: profileImage,
    );

    // Log user data
    print("User Model data: ${userModel.toMap()}");

    // Reference to the documents
    final DocumentReference followingDoc =
        _firestore.collection('followers').doc(userModel.userId);
    final DocumentReference userFollowerDoc =
        _firestore.collection('followers').doc(widget.userId);

    try {
      // Update or create the following list
      await followingDoc.set({
        'following': FieldValue.arrayUnion([userModel.toMap()])
        // Append to the following array
      }, SetOptions(merge: true));
      print("Following data saved successfully for ${userModel.userId}.");

      // Update or create the followers list
      await userFollowerDoc.set({
        'followers': FieldValue.arrayUnion([userModel.toMap()])
        // Append to the followers array
      }, SetOptions(merge: true));
      print("Follower data saved successfully for ${widget.userId}.");
    } catch (e, stackTrace) {
      // Improved error handling
      print("Error saving follower data: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> _removeFollower() async {
    // Remove the user from the following list
    final DocumentReference followingDoc =
        _firestore.collection('followers').doc(currentUser?.uid);
    followingDoc.set({
      'following': FieldValue.arrayRemove([widget.userId])
    }, SetOptions(merge: true));

    // Optionally, also update the user's follower document
    final DocumentReference userFollowerDoc =
        _firestore.collection('followers').doc(widget.userId);
    userFollowerDoc.set({
      'followers': FieldValue.arrayRemove([currentUser?.uid])
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Get the current user
    User? currentUser = _auth.currentUser;
    User? user = _auth.currentUser;
    if (currentUser == null) {
      return Center(child: Text("No user logged in"));
    }

    // Use ValueNotifier to manage the state

    final ValueNotifier<bool> isFollowing = ValueNotifier(false);
    Map<String, dynamic> userData = {};

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection("users").doc(widget.userId).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading..."); // Show loading text while fetching
            }
            if (userSnapshot.hasError) {
              return Text("Error: ${userSnapshot.error}"); // Handle error
            }
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return Text("User not found"); // Handle user not found
            }

            var userData = userSnapshot.data!;
            // Return user's name from the fetched data
            String userName = userData["Name"] ??
                "User"; // Default to 'User' if name doesn't exist
            return Text(
                userName); // Set the user name as the title in the AppBar
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection("users").doc(widget.userId).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text("Error: ${userSnapshot.error}"));
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: Text("User not found"));
          }

          var userData = userSnapshot.data!;

          // var userData = snapshot.data!.data() as Map<String, dynamic>;
          var userId = user!.uid;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display user profile information
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: userData["profileImage"] != null &&
                              userData["profileImage"].isNotEmpty
                          ? NetworkImage(userData["profileImage"])
                          : AssetImage('assets/images/default_photo.jpg')
                              as ImageProvider,
                    ),
                    SizedBox(width: 16),
                    /*Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData["Name"],
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          userData["Email"] ?? 'Email not available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),*/
                    Container(
                      width: 258,
                      height: 40,
                      child: StreamBuilder(
                        stream: _firestore
                            .collection('posts')
                            .where('userId', isEqualTo: widget.userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(child: Text("No posts available"));
                          }

                          // Get posts from snapshot
                          final posts = snapshot.data!.docs;
                          return Container(
                            height: 100,
                            child: ListView.builder(
                              itemCount: 1,
                              // We only need one item for the summary
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 22),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: <Widget>[
                                          Text(
                                            "${posts.length}",
                                            // Display the total number of posts
                                            style: TextStyle(
                                              fontFamily: myConstants.RobotoM,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            posts.length == 1
                                                ? 'Post'
                                                : 'Posts',
                                            // Use plural if there are multiple posts
                                            style: TextStyle(
                                              fontFamily: myConstants.RobotoR,
                                              fontSize: 19,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FollowersList(userId: userId),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              "852",
                                              // Placeholder for followers
                                              style: TextStyle(
                                                fontFamily: myConstants.RobotoM,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              'Followers',
                                              style: TextStyle(
                                                fontFamily: myConstants.RobotoR,
                                                fontSize: 19,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Text(
                                            "756", // Placeholder for following
                                            style: TextStyle(
                                              fontFamily: myConstants.RobotoM,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            'Following',
                                            style: TextStyle(
                                              fontFamily: myConstants.RobotoR,
                                              fontSize: 19,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  userData["Name"],
                  style: TextStyle(
                    fontFamily: myConstants.RobotoR,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  userData["Bio"],
                  style: TextStyle(
                    fontFamily: myConstants.RobotoR,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ValueListenableBuilder<bool>(
                      valueListenable: isFollowing,
                      builder: (context, value, child) {
                        return ElevatedButton(
                          // onPressed: toggleFollow,
                          onPressed: _toggleFollow,
                          child: Text(
                            value ? 'Following' : 'Follow',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: myConstants
                                  .RobotoR, // Use your font constant here
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                CupertinoColors.systemBlue.withOpacity(0.8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 51, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        'Message',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: myConstants.RobotoR,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        padding:
                            EdgeInsets.symmetric(horizontal: 48, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                      ),
                      child: Icon(CupertinoIcons.person_badge_plus),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection("posts")
                      .where("userId", isEqualTo: widget.userId)
                      .snapshots(),
                  builder: (context, postsSnapshot) {
                    if (postsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (postsSnapshot.hasError) {
                      return Center(
                          child: Text("Error: ${postsSnapshot.error}"));
                    }
                    if (!postsSnapshot.hasData ||
                        postsSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No posts available"));
                    }

                    return ListView.builder(
                      itemCount: postsSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var postDoc = postsSnapshot.data!.docs[index];
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundImage: userData["profileImage"] !=
                                                null &&
                                            userData["profileImage"].isNotEmpty
                                        ? NetworkImage(userData["profileImage"])
                                        : AssetImage(
                                                'assets/images/default_photo.jpg')
                                            as ImageProvider,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    postDoc["userName"],
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: myConstants.RobotoR,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(postDoc["description"]),
                              SizedBox(height: 8),
                              if (postDoc["imageUrl"] != null)
                                Image.network(
                                  postDoc["imageUrl"],
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
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
          );
        },
      ),
    );
  }
}
