class PersonalInfoModel {
  final String image;
  final DateTime timestamp;

  PersonalInfoModel({
    required this.image,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PersonalInfoModel.fromMap(Map<String, dynamic> map) {
    return PersonalInfoModel(
      image: map['image'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}