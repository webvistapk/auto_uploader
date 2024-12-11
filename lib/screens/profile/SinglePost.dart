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
  final VoidCallback onPostUpdated;

  SinglePost({Key? key, 
  required this.postId, 
  this.isInteractive = false,
  required this.onPostUpdated,
  })
      : super(key: key);

  @override
  State<SinglePost> createState() => _SinglePostState();
}
class _SinglePostState extends State<SinglePost> {
  bool isUserPost = false;

  @override
  void initState() {
    super.initState();
    if (widget.isInteractive == true) isUserPost = true;
    // Fetch the single post from the provider if available
    final postProvider = context.read<PostProvider>();
    if (postProvider.posts != null) {
      var post = postProvider.posts!.firstWhere(
        (post) => post.id.toString() == widget.postId,
     // Return null if no post is found
      );
      if (post != null) {
        postProvider.setSinglePost(post); // Use this to set the post if it's found in the list
      } else {
        postProvider.getSinglePost(widget.postId); // Otherwise, fetch it from the API
      }
    } else {
      postProvider.getSinglePost(widget.postId); // Fetch if posts list is empty or null
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.onPostUpdated(); // Call the callback when the screen is popped
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
            if (postProvider.post == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final post = postProvider.post!;
            var mediaList = post.media.map((media) => "${media.file}").toList();

            return PostWidget(
              postId: post.id.toString(),
              username: post.user.username,
              location: "Location",
              date: post.createdAt.toString(),
              caption: post.post,
              mediaUrls: mediaList,
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
                        videoUrl: "${mediaList[0]}",
                      ),
                      context: context,
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => postFullScreen(mediaUrls: mediaList, initialIndex: 0),
                    ),
                  );
                }
              },
              onPressLiked: () {
                // Toggle like status
                if (post.is_liked == false) {
                  postProvider.newLikes(post.id, context);
                } else {
                  postProvider.userDisLikes(post.id, context,);
                }
              },
              isLiked: post.is_liked,  // Use the actual 'isLiked' value from the post
            );
          },
        ));
  }
}
