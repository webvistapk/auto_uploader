// import 'package:intl/intl.dart';

// import '../../../models/UserProfile/post_model.dart';

// class MessageModel {
//   final int id;
//   final int senderId;
//   final String senderUsername;
//   final String senderFirstName;
//   final String senderLastName;
//   final String content;
//   final String createdAt;
//   final List<dynamic> media; // Media list
//   final List<dynamic> keywords; // Keywords list
//   final List<dynamic> tags; // Tags list
//   final PostModel? post;

//   MessageModel(
//       {required this.id,
//       required this.senderId,
//       required this.senderUsername,
//       required this.senderFirstName,
//       required this.senderLastName,
//       required this.content,
//       required this.createdAt,
//       required this.media,
//       required this.keywords,
//       required this.tags,
//       this.post});

//   // From JSON
//   factory MessageModel.fromJson(Map<String, dynamic> json) {
//     return MessageModel(
//         id: json['id'] ?? 0,
//         senderId: json['sender']?['id'] ?? 0, // Handle nested null safely
//         senderUsername: json['sender']?['username'] ?? '',
//         senderFirstName: json['sender']?['first_name'] ?? '',
//         senderLastName: json['sender']?['last_name'] ?? '',
//         content: json['message'] ?? '', // Map 'message' field
//         createdAt: json['created_at'] ?? '',
//         media: json['media'] ?? [],
//         keywords: json['keywords'] ?? [],
//         tags: json['tags'] ?? [],
//         post: json['post'] != null ? PostModel.fromJson(json['post']) : null);
//   }

//   // To JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'sender': {
//         'id': senderId,
//         'username': senderUsername,
//         'first_name': senderFirstName,
//         'last_name': senderLastName,
//       },
//       'message': content,
//       'created_at': createdAt,
//       'media': media,
//       'keywords': keywords,
//       'tags': tags,
//       'post': post != null ? PostModel.postModelToJson(post!) : null
//     };
//   }

//   // Helper method to display formatted message time (optional)
//   String formatDateString(String dateString) {
//     try {
//       final DateTime dateTime = DateTime.parse(dateString);
//       final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
//       return formatter.format(dateTime);
//     } catch (e) {
//       print('Error parsing date: $e');
//       return 'Invalid date';
//     }
//   }
// }
import 'package:intl/intl.dart';

import '../../../models/UserProfile/post_model.dart';

class MessageModel {
  final int id;
  final int senderId;
  final String senderUsername;
  final String senderFirstName;
  final String senderLastName;
  final String senderProfileImage; // Added this field
  final String content;
  final String createdAt;
  final String updatedAt; // Added updatedAt
  final List<dynamic> media; // Media list
  final List<dynamic> keywords; // Keywords list
  final List<dynamic> tags; // Tags list
  final PostModel? post;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderProfileImage,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.media,
    required this.keywords,
    required this.tags,
    this.post,
  });

  // From JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] ?? {};
    return MessageModel(
      id: json['id'] ?? 0,
      senderId: sender['id'] ?? 0,
      senderUsername: sender['username'] ?? '',
      senderFirstName: sender['first_name'] ?? '',
      senderLastName: sender['last_name'] ?? '',
      senderProfileImage: sender['profile_image'] ?? '',
      content: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      media: json['media'] ?? [],
      keywords: json['keywords'] ?? [],
      tags: json['tags'] ?? [],
      post: json['post'] != null ? PostModel.fromJson(json['post']) : null,
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
        'profile_image': senderProfileImage,
      },
      'message': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'media': media,
      'keywords': keywords,
      'tags': tags,
      'post': post != null ? PostModel.postModelToJson(post!) : null,
    };
  }

  // Helper method to display formatted message time (optional)
  String formatDateString(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }
}
