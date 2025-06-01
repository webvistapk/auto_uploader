import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/controller/services/StatusProvider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/story/create_story_screen.dart';
import 'package:mobile/screens/story/widget/status_view_screen.dart';
import 'package:provider/provider.dart';

class UsersStoryScreen extends StatefulWidget {
  final UserProfile userProfile;
  final String token;
  const UsersStoryScreen(
      {super.key, required this.userProfile, required this.token});

  @override
  State<UsersStoryScreen> createState() => _UsersStoryScreenState();
}

class _UsersStoryScreenState extends State<UsersStoryScreen> {
  @override
  Widget build(BuildContext context) {
   
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Consumer<MediaProvider>(
          builder: (context, mediaProvider, child) {
            final stories = mediaProvider.statuses
                // ??
                //     mediaProvider.followersStatus?.stories
                ;

            // Define profileImageUrl to be accessible in both the if and else blocks
            final profileImageUrl = (stories != null &&
                    stories.isNotEmpty &&
                    stories.first.user?.profileImage != null)
                ? '${stories.first.user!.profileImage}'
                : AppUtils.userImage; // Fallback URL for profile image
          print("Profile Image :${profileImageUrl}");
            if (stories != null && stories.isNotEmpty) {
              final List<Object?> allMediaFiles = stories.expand((story) {
                //debugger();
                return story.media!
                    .map((media) => media.file)
                    .whereType<String>();
              }).toList();

              final List<int?> storyIds =
                  stories.map((story) => story.id).whereType<int>().toList();
                  
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatusView(
                        statuses: allMediaFiles,
                        initialIndex: 0,
                        // isVideo: false,
                        viewers: [],
                        userProfile: widget.userProfile,
                        token: widget.token,
                        isUser: true,
                        statusId: storyIds,
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.userProfile.profileUrl==null?
                      "${AppUtils.userImage.toString()}":"${ApiURLs.baseUrl.replaceAll("/api/", '')}${widget.userProfile.profileUrl.toString()}"),
                      
                    ),
                    Positioned(
                        bottom: 0,
                        left: 28,
                        right: 0,
                        child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Image.asset(
                              AppIcons.addIcon,
                              height: 7,
                            )))
                  ],
                ),
              );
            } else {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => StoryScreen(
                        userProfile: widget.userProfile,
                        token: widget.token,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.userProfile.profileUrl==null?
                      "${AppUtils.userImage.toString()}":"${ApiURLs.baseUrl.replaceAll("/api/", '')}${widget.userProfile.profileUrl.toString()}"),
                ),
              );
            }
          },
        ));
  }
}
