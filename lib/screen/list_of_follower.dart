import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inten/model/follower_model.dart';

class FollowersList extends StatefulWidget {
  final String userId;

  const FollowersList({Key? key, required this.userId}) : super(key: key);

  @override
  _FollowersListState createState() => _FollowersListState();
}

class _FollowersListState extends State<FollowersList> {
  List<FollowerModel> _followers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFollowers();
  }

  Future<void> _fetchFollowers() async {
    try {
      DocumentSnapshot userFollowerDoc = await FirebaseFirestore.instance
          .collection('followers')
          .doc(widget.userId)
          .get();

      if (userFollowerDoc.exists) {
        List<dynamic> followersData = userFollowerDoc['followers'] ?? [];
        setState(() {
          _followers = followersData
              .map((follower) => FollowerModel.fromMap(follower))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching followers: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Followers"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _followers.length,
        itemBuilder: (context, index) {
          final follower = _followers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(follower.userProfile),
            ),
            title: Text(follower.userName),
            subtitle: Text(follower.userId),
            onTap: () {
              // Handle follower tap (e.g., navigate to profile)
            },
          );
        },
      ),
    );
  }
}