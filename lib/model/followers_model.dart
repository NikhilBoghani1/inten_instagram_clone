class UserModel {
  final String userId;
  final String userName;
  final String userProfile;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userProfile,
  });

  // Method to convert a Firestore document to a UserModel instance
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown', // Default if name is not provided
      userProfile: data['userProfile'] ?? '',  // Default if profile is not provided
    );
  }

  // Method to convert a UserModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfile': userProfile,
    };
  }
}