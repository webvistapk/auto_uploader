import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/screens/profile/imageFullScreen.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:mobile/screens/profile/widgets/ReelPostGrid.dart';
import 'package:provider/provider.dart';
import '../../common/utils.dart';
import '../../controller/endpoints.dart';

class SinglePost extends StatefulWidget {
  final String postId;
  final bool isInteractive;
  SinglePost({Key? key, required this.postId, this.isInteractive = false})
      : super(key: key);

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  bool isUserPost = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isInteractive == true) isUserPost = true;
    context.read<PostProvider>().getSinglePost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back)),
        ),
        body: Consumer<PostProvider>(
          builder: (context, postProvider, child) {
            // Fetch post if not loaded
            if (postProvider.post == null) {
              // Fetch post data from API if not already loaded

              return const Center(child: CircularProgressIndicator());
            }

            final post = postProvider.post;
            var medaiList =
                post!.media.map((media) => "${media.file}").toList();
            return PostWidget(
                postId: post.id.toString(),
                username: post.user.username,
                location: "Location",
                date: post.createdAt.toString(),
                caption: post.post,
                mediaUrls: post.media.map((media) => "${media.file}").toList(),
                profileImageUrl: post.user.profileImage != null
                    ? "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.user.profileImage}"
                    : AppUtils.userImage,
                isVideo: post.media[0].mediaType == 'video',
                likes: post.likesCount.toString(),
                comments: post.commentsCount.toString(),
                shares: "100",
                saved: '100',
                showCommentSection: true,
                refresh: () => postProvider.getSinglePost(widget.postId),
                isUserPost: isUserPost,
                onPressed: () {
                  if (post.media[0].mediaType == 'video') {
                    Navigator.push(
                      context,
                      CupertinoDialogRoute(
                        builder: (_) => FullscreenVideoPlayer(
                          videoUrl: "${medaiList[0]}",
                        ),
                        context: context,
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => postFullScreen(
                              mediaUrls: medaiList, initialIndex: 0)),
                    );
                  }
                });
          },
        ));
  }
}
