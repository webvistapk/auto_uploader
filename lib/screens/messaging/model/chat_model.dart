class ChatModel {
  final int id;
  final String? name;
  final List<Participant> participants; // List of participant details
  final bool isGroup;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.name,
    required this.participants,
    required this.isGroup,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a ChatModel from JSON
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'],
      participants: (json['participants'] as List)
          .map((participant) => Participant.fromJson(participant))
          .toList(),
      isGroup: json['is_group'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Participant {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profileImage; // Nullable field

  Participant({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  // Factory method to create a Participant from JSON
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
    );
  }
}
