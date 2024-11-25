class ChatModel {
  final int id;
  final String name;
  final List<String> participantsUsernames; // List of participants' usernames
  final bool isGroup;
  final String time; // You may want to set a proper timestamp from the backend
  final String message; // Example message, you can customize it further

  ChatModel({
    required this.id,
    required this.name,
    required this.participantsUsernames,
    required this.isGroup,
    required this.time,
    required this.message,
  });

  // Factory method to create a ChatModel from JSON
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'],
      participantsUsernames: List<String>.from(json['participants_usernames']),
      isGroup: json['is_group'],
      time:
          DateTime.now().toString(), // Adjust as necessary for your time format
      message:
          'Welcome Come back!', // You can update this based on the chat history
    );
  }
}
