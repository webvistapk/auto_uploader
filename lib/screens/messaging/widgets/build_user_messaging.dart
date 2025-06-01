// import 'package:flutter/material.dart';
// import 'package:mobile/common/app_colors.dart';
// import 'package:mobile/common/app_text_styles.dart';
// import 'package:mobile/models/UserProfile/post_model.dart';
// import 'package:mobile/models/UserProfile/userprofile.dart';
// import 'package:mobile/screens/messaging/model/message_model.dart';
// import 'package:mobile/screens/messaging/widgets/media_item.dart';
// import 'package:mobile/screens/messaging/widgets/message_video_player.dart';
// import 'package:mobile/screens/profile/SinglePost.dart';
// import 'package:mobile/utils/custom_navigations.dart';

// class UnifiedMessage extends StatelessWidget {
//   final bool isOwnMessage;
//   final String text;
//   final String timestamp;
//   final List<dynamic> mediaList;
//   final UserProfile? userProfile;
//   final PostModel? post;

//   const UnifiedMessage({
//     Key? key,
//     required this.isOwnMessage,
//     required this.text,
//     required this.timestamp,
//     required this.mediaList,
//     this.userProfile,
//     this.post,
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

//           // Show Post if available
//           if (post != null) ...[
//             if (post != null)
//               InkWell(
//                 onTap: () {
//                   // debugger();
//                   push(
//                       context,
//                       SinglePost(
//                           postId: post!.id.toString(), onPostUpdated: () {}));
//                 },
//                 child: Container(
//                   width: 300,
//                   margin: const EdgeInsets.only(left: 50, bottom: 8.0),
//                   padding: const EdgeInsets.all(12),
//                   // constraints: BoxConstraints(
//                   //   maxWidth: MediaQuery.of(context).size.width * 0.7,
//                   // ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.shade400.withOpacity(0.5),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (post!.postTitle != null)
//                         Text(
//                           post!.postTitle!,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       if (post!.postDescription != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 6.0),
//                           child: Text(
//                             post!.postDescription!,
//                             style: const TextStyle(color: Colors.black54),
//                           ),
//                         ),
//                       if (post!.media.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8.0),
//                           child: Column(
//                             children: post!.media.map((media) {
//                               return MediaItem(
//                                 url: media.file,
//                                 mediaType: media.mediaType,
//                                 timestamp: timestamp,
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],

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
//               margin: const EdgeInsets.only(top: 8.0),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isOwnMessage
//                     ? const Color.fromARGB(255, 103, 207, 255)
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

import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/model/message_model.dart';
import 'package:mobile/screens/messaging/widgets/media_item.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/utils/custom_navigations.dart';

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

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                timestamp,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),

          // Post Preview Box
          if (post != null)
            InkWell(
              onTap: () {
                push(
                  context,
                  SinglePost(
                    postId: post!.id.toString(),
                    onPostUpdated: () {},
                  ),
                );
              },
              child: Container(
                width: 100,
                height: 150,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Replied to Post",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post!.postTitle ?? 'No Title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),

                    if (post!.media.isNotEmpty) ...[
                      Column(
                        children: post!.media.map((media) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                // Image/Video Thumbnail

                                Image.network(
                                  media.file,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),

                                // Play icon overlay for videos
                                if (media.mediaType == 'video')
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black26,
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ]
                    // Expanded(
                    //   child: Text(
                    //     post!.postDescription ?? 'No Description',
                    //     maxLines: 3,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: const TextStyle(
                    //       fontSize: 13,
                    //       color: Colors.black54,
                    //     ),
                    //   ),
                    // ),
                    // if (post!.media.isNotEmpty)
                  ],
                ),
              ),
            ),

          // Media (if any in message directly)
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

          // Message Text
          if (text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? const Color.fromARGB(255, 103, 207, 255)
                    : Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft:
                      isOwnMessage ? const Radius.circular(12) : Radius.zero,
                  bottomRight:
                      !isOwnMessage ? const Radius.circular(12) : Radius.zero,
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
