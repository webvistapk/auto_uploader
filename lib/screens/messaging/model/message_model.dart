import 'package:intl/intl.dart';

class MessageModel {
  final int id;
  final int sender;
  final String senderUsername;
  final String content;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.sender,
    required this.senderUsername,
    required this.content,
    required this.createdAt,
  });

  // From JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0, // Provide a default value for `id`
      sender: json['sender'] ?? '', // Provide a default value for `sender`
      content: json['content'] ?? '', // Default for content
      createdAt: json['created_at'] ?? '',
      senderUsername: json['sender_username'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'sender_username': senderUsername,
      'content': content,
      'created_at': createdAt,
    };
  }

  // Helper method to display formatted message time (optional)
  String formatDateString(String dateString) {
    try {
      // Parse the input string into a DateTime object
      DateTime dateTime = DateTime.parse(dateString);

      // Define the format you want (e.g., "yyyy-MM-dd HH:mm:ss")
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

      // Format the DateTime object to the specified format
      return formatter.format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }
}
