import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/messaging/widgets/media_item.dart';

class PostMessageWidget extends StatelessWidget {
  final String text;
  final String timestampDate;
  final String timestampTime;
  final List<dynamic> mediaList;
  final PostModel? post; // NEW: Optional post object

  const PostMessageWidget({
    Key? key,
    required this.text,
    required this.timestampDate,
    required this.timestampTime,
    required this.mediaList,
    this.post, // NEW
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Date
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                timestampDate,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),

          // Media (in the message)
          if (mediaList.isNotEmpty)
            Column(
              children: mediaList.map((media) {
                return MediaItem(
                  url: media['file'],
                  mediaType: media['media_type'],
                  timestamp: timestampTime,
                );
              }).toList(),
            ),

          // Text message bubble
          if (text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 55, top: 8.0),
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 103, 207, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                text,
                style: AppTextStyles.poppinsRegular(color: AppColors.white),
                softWrap: true,
              ),
            ),

          // NEW: If there's a post, show it below
          if (post != null)
            Container(
              margin: const EdgeInsets.only(left: 55, top: 8.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post!.postTitle != null)
                    Text(
                      post!.postTitle!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  if (post!.postDescription != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(post!.postDescription!),
                    ),
                  if (post!.media.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: post!.media.map((media) {
                          return MediaItem(
                            url: media.file,
                            mediaType: media.mediaType,
                            timestamp: timestampTime,
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

          // Timestamp time
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              timestampTime,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
