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

  const PostMessageWidget({
    Key? key,
    required this.text,
    required this.timestampDate,
    required this.timestampTime,
    required this.mediaList,
    this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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
                // debugger();
                push(
                    context,
                    SinglePost(
                        postId: post!.id.toString(), onPostUpdated: () {}));
              },
              child: Container(
                margin: const EdgeInsets.only(left: 50, bottom: 8.0),
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post!.postTitle != null)
                      Text(
                        post!.postTitle!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    if (post!.postDescription != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          post!.postDescription!,
                          style: const TextStyle(color: Colors.black54),
                        ),
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
