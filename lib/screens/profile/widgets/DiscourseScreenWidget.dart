import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/screens/profile/imageFullScreen.dart';
import 'package:mobile/screens/profile/widgets/ReelPostGrid.dart';
import 'package:mobile/screens/profile/widgets/discoursePostWidget.dart';
import 'package:provider/provider.dart';

class DiscourseScreen extends StatefulWidget {
  final UserProfile? userProfile;
  const DiscourseScreen({super.key, required this.userProfile});

  @override
  State<DiscourseScreen> createState() => _DiscourseScreenState();
}

class _DiscourseScreenState extends State<DiscourseScreen> {
  int _offset = 0;
  bool _isLoadingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        _fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchPosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    setState(() {
      _isLoadingMore = true;
    });

    await postProvider.fetchFollowerPost(
      context,
      limit: 10,
      offset: _offset,
      postType: "discourse",
    );

    setState(() {
      _offset += 10;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        final posts = postProvider.posts ?? [];

        return Column(
          children: [
            Center(
              child: Text(
                "03/28/23 at 4:58 AM",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: 'fontBold',
                  color: Color(0xff77797A),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final fullMediaUrls = post.media.map((m) => m.file).toList();

                  return DiscoursePostWidget(
                    postID: post.id.toString(),
                    userID: post.user.id.toString(),
                    fullName: "${post.user.firstName} ${post.user.lastName}",
                    clubName: "Club Name",
                    profileUrl: post.user.profileImage?.isNotEmpty == true
                        ? post.user.profileImage!
                        : AppUtils.userImage,
                    mediaUrls: fullMediaUrls,
                    content: post.post,
                    isVideo:
                        post.media.any((media) => media.mediaType == 'video')
                            ? true
                            : false,
                    goToSinglePost: () {
                      if (post.media[0].mediaType == 'video') {
                        Navigator.push(
                          context,
                          CupertinoDialogRoute(
                            builder: (_) => FullscreenVideoPlayer(
                              videoUrl: "${fullMediaUrls[0]}",
                            ),
                            context: context,
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => postFullScreen(
                                mediaUrls: fullMediaUrls, initialIndex: 0),
                          ),
                        );
                      }
                    },
                    onPressLiked: () async {
                      final postProvider =
                          Provider.of<PostProvider>(context, listen: false);

                      if (post.isLiked == false) {
                        // Like the post
                        await postProvider.newLikes(
                          post.id,
                          context,
                        );
                      } else {
                        // Dislike the post
                        await postProvider.userDisLikes(
                          post.id,
                          context,
                        );
                      }
                    },
                    isPostLiked:  post.isLiked,
                  );
                },
              ),
            ),
            if (_isLoadingMore)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
