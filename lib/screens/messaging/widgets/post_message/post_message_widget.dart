import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/controller/endpoints.dart';
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

  const PostMessageWidget({
    Key? key,
    required this.text,
    required this.timestampDate,
    required this.timestampTime,
    required this.mediaList,
    this.post,
    required this.isUser,
  }) : super(key: key);

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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
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
                height: 150, // Adjust height as needed
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 8,
                        spreadRadius: 2)
                  ],
                ),
                child: Stack(
                  children: [
                    // Image as the background
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        '${ApiURLs.baseUrl2}${post!.media.first.file}', // Assuming the first media is the image
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                    // Grey overlay with opacity
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          color: Colors.black.withOpacity(
                              0.4), // Semi-transparent grey overlay
                        ),
                      ),
                    ),
                    // "Replied to Post" text on top
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Text(
                        "Replied to Post",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (mediaList.isNotEmpty)
            Column(
              children: mediaList.map((media) {
                return MediaItem(
                  url: media['file'],
                  mediaType: media['media_type'],
                  timestamp: timestampTime,
                  isUser: true,
                );
              }).toList(),
            ),
          // Post message bubble below image, with blue bubble style
          if (text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 55, top: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFF68CFFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blueAccent.shade100,
                      blurRadius: 6,
                      spreadRadius: 2)
                ],
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
