import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String description;
  String id;
  String userId;
  String userName;
  String profileImage;
  final String imageUrl;
  Timestamp timestamp;
  int likeCount; // Add like count property
  bool isSaved; // Add isSaved property

  PostModel({
    required this.description,
    required this.id,
    required this.userId,
    required this.userName,
    required this.profileImage,
    required this.imageUrl,
    required this.timestamp,
    this.likeCount = 0, // Initialize default like count
    this.isSaved = false, // Initialize default isSaved value
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'userId': userId,
      'userName': userName,
      'profileImage': profileImage,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'likeCount': likeCount, // Include like count in the map
      'isSaved': isSaved, // Include isSaved in the map
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      description: map['description'] ?? '',
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      profileImage: map['profileImage'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      likeCount: map['likeCount'] ?? 0, // Ensure like count is available
      isSaved: map['isSaved'] ?? false, // Ensure isSaved is available
    );
  }
}

/*
class PostModel {
  String id;         // Post ID
  String userId;     // User ID of the poster
  String userName;   // Username of the poster
  String profileImage; // Profile image URL
  String description; // Post description
  String imageUrl;   // Post image URL
  Timestamp timestamp; // Time the post was created
  bool isLiked;         // Like count for the post

  PostModel({
    required this.id,
    required this.userId,     // Include userId in constructor
    required this.userName,
    required this.profileImage,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    this.isLiked = false,          // Initialize likes count to zero
  });

  // Method to convert Firestore data to PostModel
  factory PostModel.fromMap(Map<String, dynamic> data) {
    return PostModel(
      id: data['postId'],
      userId: data['userId'], // Retrieve userId from Firestore
      userName: data['userName'],
      profileImage: data['profileImage'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'],
      isLiked: data['isLiked'] ?? false, // Safely retrieve likes count
    );
  }

  // Method to convert PostModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'postId': id,
      'userId': userId,           // Include userId in map
      'userName': userName,
      'profileImage': profileImage,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'isLiked': isLiked,             // Include likes count in map
    };
  }
}*/
