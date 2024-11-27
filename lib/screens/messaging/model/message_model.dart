import 'package:intl/intl.dart';

class MessageModel {
  final int id;
  final int senderId;
  final String senderUsername;
  final String senderFirstName;
  final String senderLastName;
  final String content;
  final String createdAt;
  final List<dynamic>
      media; // Assuming media is a list, you can refine the type
  final List<dynamic> keywords; // Assuming keywords is a list, refine if needed
  final List<dynamic> tags; // Assuming tags is a list, refine if needed

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.senderFirstName,
    required this.senderLastName,
    required this.content,
    required this.createdAt,
    required this.media,
    required this.keywords,
    required this.tags,
  });

  // From JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      senderId: json['sender']['id'] ?? 0, // sender id from nested object
      senderUsername: json['sender']['username'] ?? '',
      senderFirstName: json['sender']['first_name'] ?? '',
      senderLastName: json['sender']['last_name'] ?? '',
      content: json['message'] ?? '', // Map 'message' field from the response
      createdAt: json['created_at'] ?? '',
      media: json['media'] ?? [], // Ensure it's an empty list if no media
      keywords: json['keywords'] ?? [], // Default to an empty list
      tags: json['tags'] ?? [], // Default to an empty list
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': {
        'id': senderId,
        'username': senderUsername,
        'first_name': senderFirstName,
        'last_name': senderLastName,
      },
      'message': content,
      'created_at': createdAt,
      'media': media,
      'keywords': keywords,
      'tags': tags,
    };
  }

  // Helper method to display formatted message time (optional)
  String formatDateString(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }
}
