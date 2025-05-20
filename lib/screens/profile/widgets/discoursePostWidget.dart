import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/controller/function/commentBottomSheet.dart';
import 'package:mobile/controller/function/postfunctions.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/profile/widgets/DiscoursePost.dart';

class DiscoursePostWidget extends StatelessWidget {
  final String postID;
  final String userID;
  final String fullName;
  final String clubName;
  final String profileUrl;
  final List<String> mediaUrls;
  final String content;
  final bool isVideo;
  final goToSinglePost;
  final onPressLiked;
  final bool isPostLiked;
  const DiscoursePostWidget(
      {super.key,
      required this.postID,
      required this.userID,
      required this.fullName,
      required this.clubName,
      required this.profileUrl,
      required this.mediaUrls,
      required this.content,
      required this.isVideo,
      required this.goToSinglePost,
      required this.onPressLiked,
      required this.isPostLiked

      });

  @override
  Widget build(BuildContext context) {
    print("LIKED: ${isPostLiked}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 48, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fullName,
                  style: TextStyle(fontSize: 24.sp, fontFamily: 'fontBold'),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.sp, vertical: 12.sp),
                  decoration: BoxDecoration(
                    color: const Color(0XFFFF0047),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    clubName,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(profileUrl),
              ),
              Expanded(
                child: DiscoursePost(
                  mediaUrls: mediaUrls,
                  content: content,
                  isVideo: isVideo,
                  onPressed: goToSinglePost,
                ),
              ),
            ],
          ),
          SizedBox(height: 23.46.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () {
                    CreateChat(userID, postID, context, isEmoji: false);
                  },
                  child: Image.asset(AppIcons.forward, width: 22.6.sp)),
              SizedBox(width: 57.74.sp),
              Image.asset(AppIcons.repost, width: 22.6.sp),
              SizedBox(width: 57.74.sp),
              GestureDetector(
                onTap: onPressLiked,
                child: Image.asset(isPostLiked
                                        ? AppIcons.heart_filled
                                        : AppIcons.heart,
                    width: 22.6.sp, ),
              ),
              SizedBox(width: 57.74.sp),
              GestureDetector(
                onTap: (){
                   showComments(postID, false, context,
                                    "",
                                    replyID: "",
                                    scrollOffset: 0,
                                    commentCount: 0,
                                    isSinglePost: false);
              
                },
                child: Image.asset(AppIcons.comment, width: 22.6.sp)),
            ],
          ),
        ],
      ),
    );
  }
}
