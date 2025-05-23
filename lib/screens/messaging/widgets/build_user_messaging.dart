import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/model/message_model.dart';
import 'package:mobile/screens/messaging/widgets/media_item.dart';
import 'package:mobile/screens/messaging/widgets/message_video_player.dart';

class UnifiedMessage extends StatelessWidget {
  final bool isOwnMessage;
  final String text;
  final String timestamp;
  final List<dynamic> mediaList;
  final UserProfile? userProfile;
  final PostModel? post;

  const UnifiedMessage({
    Key? key,
    required this.isOwnMessage,
    required this.text,
    required this.timestamp,
    required this.mediaList,
    this.userProfile,
    this.post,
  }) : super(key: key);

  bool isVideo(String mediaType) {
    return mediaType == 'video';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Centered Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                timestamp,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),

          // Show Post if available
          if (post != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.all(12),
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color:
                    isOwnMessage ? Colors.blue.shade100 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post!.post ?? 'No Title',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post!.post ?? 'No Description',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (post!.media != null && post!.media.isNotEmpty)
                    Column(
                      children: (post!.media).map((media) {
                        return MediaItem(
                          url: media.file,
                          mediaType: media.mediaType,
                          timestamp: timestamp,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],

          // Media Gallery
          if (mediaList.isNotEmpty)
            Column(
              children: mediaList.map((media) {
                return MediaItem(
                  url: media['file'],
                  mediaType: media['media_type'],
                  timestamp: timestamp,
                );
              }).toList(),
            ),

          // Message Bubble
          if (text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? const Color.fromARGB(255, 103, 207, 255)
                    : Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft:
                      isOwnMessage ? Radius.circular(12) : Radius.circular(0),
                  bottomRight:
                      !isOwnMessage ? Radius.circular(12) : Radius.circular(0),
                ),
              ),
              child: Text(
                text,
                style: AppTextStyles.poppinsRegular(color: AppColors.white),
                softWrap: true,
              ),
            ),

          // Sending Time
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              timestamp,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// class UnifiedMessage extends StatelessWidget {
//   final bool
//       isOwnMessage; // Flag to determine if the message is sent by the current user
//   final String text;
//   final String timestamp;
//   final List<dynamic> mediaList;
//   final UserProfile? userProfile; // Include user profile if needed

//   const UnifiedMessage({
//     Key? key,
//     required this.isOwnMessage,
//     required this.text,
//     required this.timestamp,
//     required this.mediaList,
//     this.userProfile,
//   }) : super(key: key);

//   bool isVideo(String mediaType) {
//     return mediaType == 'video';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
//       child: Column(
//         crossAxisAlignment:
//             isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           // Centered Timestamp
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Center(
//               child: Text(
//                 timestamp,
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ),
//           ),
//           // Media Gallery
//           if (mediaList.isNotEmpty)
//             Column(
//               children: mediaList.map((media) {
//                 return MediaItem(
//                   url: media['file'],
//                   mediaType: media['media_type'],
//                   timestamp: timestamp,
//                 );
//               }).toList(),
//             ),
//           // Message Bubble
//           if (text.isNotEmpty)
//             Container(
//               margin: const EdgeInsets.only(right: 20),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isOwnMessage
//                     ? Color.fromARGB(255, 103, 207, 255)
//                     : Colors.grey,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                   bottomLeft:
//                       isOwnMessage ? Radius.circular(12) : Radius.circular(0),
//                   bottomRight:
//                       !isOwnMessage ? Radius.circular(12) : Radius.circular(0),
//                 ),
//               ),
//               child: Text(
//                 text,
//                 style: AppTextStyles.poppinsRegular(color: AppColors.white),
//                 softWrap: true,
//               ),
//             ),
//           // Sending Time
//           Padding(
//             padding: const EdgeInsets.only(top: 4.0),
//             child: Text(
//               timestamp,
//               style: const TextStyle(fontSize: 10, color: Colors.grey),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class buildUserMessage extends StatelessWidget {
  final String timestamp;
  final UserProfile userProfile;
  final MessageModel messageModel;
  final PostModel? post;

  const buildUserMessage({
    Key? key,
    required this.timestamp,
    required this.userProfile,
    required this.messageModel,
    this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UnifiedMessage(
      isOwnMessage: false,
      text: messageModel.content,
      timestamp: timestamp,
      mediaList: messageModel.media,
      userProfile: userProfile,
      post: post,
    );
  }
}

// class buildUserMessage extends StatelessWidget {
//   final String timestamp;
//   final UserProfile userProfile;
//   final MessageModel messageModel;
//   const buildUserMessage({
//     Key? key,
//     required this.timestamp,
//     required this.userProfile,
//     required this.messageModel,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return UnifiedMessage(
//       isOwnMessage: false,
//       text: messageModel.content,
//       timestamp: timestamp,
//       mediaList: messageModel.media,
//       userProfile: userProfile,
//     );
//   }
// }
