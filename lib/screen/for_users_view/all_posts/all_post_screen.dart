import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inten/model/post_model.dart';
import 'package:inten/screen/for_users_view/edit_post/edit_post_screen.dart';
import 'package:inten/screen/for_users_view/one_image_show/one_image_show_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllPostScreen extends StatefulWidget {
  const AllPostScreen({super.key});

  @override
  State<AllPostScreen> createState() => _AllPostScreenState();
}

class _AllPostScreenState extends State<AllPostScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Initialize current user
  }

/*  void _deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }*/

  void _showUpdateDialog(BuildContext context, PostModel post) {
    final TextEditingController _controller =
        TextEditingController(text: post.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Post'),
          content: TextField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: "Enter new description"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  await _updatePost(post.id, _controller.text);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePost(String postId, String newDescription) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'description': newDescription,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating post: $e')),
      );
    }
  }

  Future<void> _deletePost(String postId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // If confirmed, delete the post from Firestore
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      print('Post deleted: $postId');
      // Optionally show a snackbar or a success message
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
            const SnackBar(content: Text('Post removed from saved')),
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
            const SnackBar(content: Text('Post saved successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling save post: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
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
              .showSnackBar(const SnackBar(content: Text('Like removed')));
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
              .showSnackBar(const SnackBar(content: Text('Post liked')));
        }
      } catch (e) {
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      /*  This is For Virtical Post Show */
      body: Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('posts').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No posts available"));
            }

            // Get the current user's ID (Assuming you have a method to get this)
            String currentUserId = FirebaseAuth.instance.currentUser!
                .uid; // or however you get the current user's ID

            // Create a list of posts from the snapshot data and reverse the order
            final posts = snapshot.data!.docs
                .map((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>; // Cast the data
                  return PostModel.fromMap(data)
                    ..id = doc.id; // Use fromMap with safe handling
                })
                .toList()
                .reversed // Reverse the list to show the latest posts first
                .where((post) =>
                    post.userId ==
                    currentUserId) // Filter posts by current user ID
                .toList();

            // Check if there's at least one post to move to index 1
            if (posts.length > 1) {
              // Extract the last post
              final lastPost =
                  posts.removeLast(); // Remove the last post from the list
              // Insert the last post at index 1
              posts.insert(1, lastPost);
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                DateTime postDateTime =
                    post.timestamp.toDate(); // Assuming you have a timestamp
                String timeAgo = timeago.format(postDateTime); // Get time ago

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: post.profileImage.isNotEmpty
                                  ? NetworkImage(
                                      "${post.profileImage}?t=${DateTime.now().millisecondsSinceEpoch}")
                                  : const AssetImage(
                                          "assets/images/default_avatar.png")
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              post.userName.isNotEmpty
                                  ? post.userName
                                  : "Unknown User",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            PopupMenuButton(
                                icon: const Icon(CupertinoIcons.ellipsis_vertical),
                                itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                      // Add more options as necessary
                                    ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    // Handle edit action
                                    print('Edit post: ${post.id}');
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => EditPostScreen(
                                        postId: post.id,
                                        initialDescription: post.description,
                                        initialImageUrl: post
                                            .imageUrl, // Pass the image URL if needed
                                      ),
                                    ));
                                  } else if (value == 'delete') {
                                    // Handle delete action
                                    print('Delete post: ${post.id}');
                                    // Show confirmation dialog before deleting
                                    _deletePost(post
                                        .id); // Ensure this method is defined
                                  }
                                }),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(post.description),
                        const SizedBox(height: 8),
                        Text(timeAgo),
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
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              /* onTap: () {
                                      setState(() {
                                        _toggleLike(post);
                                      });
                                    },*/
                              onTap: () => _toggleLike(post),
                              child: Icon(
                                CupertinoIcons.heart_fill,
                                color: post.likeCount > 0
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(post.likeCount.toString()),
                            const SizedBox(width: 10),
                            const Icon(CupertinoIcons.chat_bubble),
                            const SizedBox(width: 10),
                            const Icon(CupertinoIcons.location),
                            const Spacer(),
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
      /*  This is For Gridvie Post Show */
     /* body: Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('posts')
              .where('userId',
                  isEqualTo: _currentUser?.uid) // Filter by current user's ID
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

            // Create a list of image URLs from the snapshot data
            final posts =
                snapshot.data!.docs; // Keep the snapshots for other details

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns
                childAspectRatio: 1, // Aspect ratio for square images
                mainAxisSpacing: 10,
              ),
              itemCount: posts.length,
              itemBuilder: (ctx, index) {
                final data = posts[index].data()
                    as Map<String, dynamic>; // Get data from snapshot

                // Safely getting values with null checks
                final imageUrl = data['imageUrl'] as String? ?? '';
                final title = data['userName'] as String? ?? 'Untitled';
                final description = data['description'] as String? ??
                    'No description available';
                final userImage =
                    data['profileImage'] as String ?? 'No Profile';
                final userName = data['userName'] as String ?? 'No Name';

                return GestureDetector(
                  onTap: () {
                    // Only navigate if imageUrl is not empty
                    if (imageUrl.isNotEmpty) {
                      // Navigate to the detail screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDetailScreen(
                            imageUrl: imageUrl,
                            title: title,
                            description: description,
                            userImage: userImage,
                            postId: posts[index].id,
                            userName: userName, // Pass userName to the next screen
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.network(
                      imageUrl.isNotEmpty
                          ? imageUrl
                          : 'https://via.placeholder.com/150', // Fallback image
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),*/
    );
  }
}
