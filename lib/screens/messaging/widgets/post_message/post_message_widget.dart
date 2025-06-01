import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/messaging/widgets/media_item.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/utils/custom_navigations.dart';

class PostMessageWidget extends StatelessWidget {
  final String text;
  final String timestampDate;
  final String timestampTime;
  final List<dynamic> mediaList;
  final PostModel? post;
  final bool isUser;

  const PostMessageWidget(
      {Key? key,
      required this.text,
      required this.timestampDate,
      required this.timestampTime,
      required this.mediaList,
      this.post,
      required this.isUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Date displayed centered above everything
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                timestampDate,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),

          // Post details container (light grey with rounded corners & slight shadow)
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

          // Text message bubble below post container, with Instagram-like blue bubble style
          if (text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(
                left: 55,
              ),
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

          // Timestamp below aligned right, small and grey
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 4.0),
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
