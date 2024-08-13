class FollowerModel {
  final String userId;
  final String userName;
  final String userProfile;

  FollowerModel({
    required this.userId,
    required this.userName,
    required this.userProfile,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfile': userProfile,
    };
  }

  factory FollowerModel.fromMap(Map<String, dynamic> map) {
    return FollowerModel(
      userId: map['userId'],
      userName: map['userName'],
      userProfile: map['userProfile'],
    );
  }
}