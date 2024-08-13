import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inten/const/constants.dart';
import 'package:inten/model/post_model.dart';
import 'package:inten/screen/for_users_view/all_posts/all_post_screen.dart';
import 'package:inten/screen/for_users_view/edit_profile/edit_profile_screen.dart';
import 'package:inten/screen/for_users_view/save_post/save_post_screen.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? currentUser = _auth.currentUser;
    User? user = _auth.currentUser;
    if (currentUser == null) {
      return Center(child: Text("No user logged in"));
    }

    Constants myConstants = Constants();

    void _showProfileOption() {
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
          return Container(
            height: 1000,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: 60,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(CupertinoIcons.settings, size: 28),
                        title: Text(
                          "Settings and privacy",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.clock, size: 28),
                        title: Text(
                          "Scheduled content",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        leading:
                            Icon(CupertinoIcons.chart_bar_alt_fill, size: 28),
                        title: Text(
                          "Insights",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.chart_pie, size: 28),
                        title: Text(
                          "Your activity",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.arrow_counterclockwise,
                            size: 28),
                        title: Text(
                          "Archive",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        leading:
                            Icon(CupertinoIcons.qrcode_viewfinder, size: 28),
                        title: Text(
                          "QR code",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.bookmark_fill, size: 28),
                        title: Text(
                          "Saved",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      /*ListTile(
                        leading: Icon(Icons.supervised_user_circle_rounded, size: 28),
                        title: Text(
                          "Supervision",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.creditcard, size: 28),
                        title: Text(
                          "Orders and payments",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.verified_outlined, size: 28),
                        title: Text(
                          "Meta Verified",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.slider_horizontal_3, size: 28),
                        title: Text(
                          "Close Friends",
                          style: TextStyle(
                              fontFamily: myConstants.RobotoR, fontSize: 18),
                        ),
                      ),*/
                    ],
                  ),
                )
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: user != null
              ? _firestore.collection('users').doc(user.uid).snapshots()
              : null,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            }

            // Check if user data exists
            if (snapshot.hasData && snapshot.data!.exists) {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String name = userData['Name'] ?? user?.email ?? "User";

              // Return the user's name as the AppBar title
              return Row(
                children: [
                  Text("Welcome, $name"),
                  SizedBox(width: 5),
                  Icon(
                    Icons.verified_rounded,
                    color: CupertinoColors.link,
                    size: 19,
                  ),
                ],
              );
            } else {
              return Text("Welcome!");
            }
          },
        ),
        actions: [
          Icon(
            CupertinoIcons.plus_app,
            size: 32,
          ),
          SizedBox(width: 15),
          GestureDetector(
            onTap: () {
              _showProfileOption();
            },
            child: Icon(
              CupertinoIcons.line_horizontal_3_decrease,
              size: 32,
            ),
          ),
          SizedBox(width: 20)
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
              stream: _firestore
                  .collection('posts')
                  .where('userId',
                      isEqualTo: currentUser.uid) // Filter by current user's ID
                  .snapshots(),
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

                final posts = snapshot.data!.docs.map((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>; // Cast the data
                  return PostModel.fromMap(data)
                    ..id = doc.id; // Use fromMap with safe handling
                }).toList();
                return Container(
                  height: 107,
                  // color: Colors.grey.withOpacity(0.2),
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: posts[index]
                                          .profileImage
                                          .isNotEmpty
                                      ? NetworkImage(posts[index].profileImage)
                                      : AssetImage(
                                              "assets/images/default_avatar.png")
                                          as ImageProvider,
                                  radius: 40,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  posts[index].userName.isNotEmpty
                                      ? posts[index].userName
                                      : "Unknown User",
                                  style: TextStyle(
                                    fontFamily: myConstants.RobotoR,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  "${posts.length}",
                                  style: TextStyle(
                                    fontFamily: myConstants.RobotoM,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Post',
                                  style: TextStyle(
                                    fontFamily: myConstants.RobotoR,
                                    fontSize: 19,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  "852",
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
                            Column(
                              children: <Widget>[
                                Text(
                                  "756",
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
            SizedBox(height: 10),
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 25),
            //   child: StreamBuilder<QuerySnapshot>(
            //     // Ensure `_firestore` is defined and holds a string user ID
            //     stream: FirebaseFirestore.instance
            //         .collection('users')
            //         .where('userId',
            //             isEqualTo:
            //                 _firestore) // Ensure _firestore contains userId as a String
            //         .snapshots(),
            //     builder: (context, snapshot) {
            //       // Handle loading state
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         print("Connection State: Waiting");
            //         return const Center(child: CircularProgressIndicator());
            //       }
            //       if (snapshot.hasError) {
            //         print("Snapshot Error: ${snapshot.error}");
            //         return Center(child: Text("Error: ${snapshot.error}"));
            //       }
            //       // Handle empty data state
            //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            //         return const Center(child: Text("No posts available"));
            //       }
            //
            //       // Get the first document safely
            //       DocumentSnapshot documentSnapshot = snapshot.data!.docs.first;
            //       String userBio = documentSnapshot['Bio'] ??
            //           'No bio available'; // Ensure 'Bio' exists
            //
            //       // Return the user's bio
            //       return Text(userBio);
            //     },
            //   ),
            // ),
            // SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: 160,
                    child: FilledButton(
                      onPressed: () async {
                        var userData = await _firestore
                            .collection('users')
                            .doc(currentUser.uid)
                            .get();
                        if (user != null) {
                          // Navigate to EditProfileScreen with current user data
                          /* Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                userId: user.uid,
                                currentName: userData['Name'] ?? "No name set",
                                currentEmail: user.email ?? "No email set",
                                currentProfilePictureUrl:
                                    userData['ProfilePicture'] ??
                                        "", // Assuming you have this field
                              ),
                            ),
                          ); */
                          Get.to(
                              EditProfileScreen(
                                userId: user.uid,
                                currentName: userData['Name'] ?? "No name set",
                                currentEmail: user.email ?? "No email set",
                                currentProfilePictureUrl:
                                    userData['profileImage'] ??
                                        "", // Assuming you have this field
                              ),
                              transition: Transition.rightToLeft,
                              duration: Duration(milliseconds: 500));
                        }
                      },
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: FilledButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Power Off',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.power_settings_new_rounded,
                            color: Colors.black,
                            size: 19,
                          ),
                        ],
                      ),
                      style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.black,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              // Use Expanded here
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: Colors.black,
                      dividerHeight: 0,
                      indicatorSize: TabBarIndicatorSize.tab,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      tabs: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.grid_view_sharp,
                                color: Colors.black,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Post",
                                style: TextStyle(
                                  fontFamily: myConstants.RobotoR,
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                CupertinoIcons.bookmark_fill,
                                color: Colors.black,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Save",
                                style: TextStyle(
                                  fontFamily: myConstants.RobotoR,
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      // Ensure that TabBarView takes the rest of the available space.
                      child: TabBarView(
                        children: [
                          AllPostScreen(),
                          SavePostScreen(),
                          /* BankView(),
                          CreditCardView(),
                          DebitCardView(),*/
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
