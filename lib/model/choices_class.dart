class ChoiceModel {
  String? id; // Make this nullable so it can be updated later.
  final String selectedChoice;
  final DateTime timestamp;

  ChoiceModel({
    this.id,
    required this.selectedChoice,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'selected_choice': selectedChoice,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChoiceModel.fromJson(String id, Map<String, dynamic> json) {
    return ChoiceModel(
      id: id,
      selectedChoice: json['selected_choice'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}