import 'package:flutter/material.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:provider/provider.dart';
import '../../common/utils.dart';
import '../../controller/endpoints.dart';

class SinglePost extends StatefulWidget {
  final String postId;
  final bool isInteractive;
  SinglePost({Key? key, required this.postId,this.isInteractive=false}) : super(key: key);

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  bool isUserPost=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.isInteractive==true)
      isUserPost=true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: Provider.of<PostProvider>(context, listen: false).getSinglePost(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load post.'));
          } else {
            return Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                final post = postProvider.post;
                if (post == null) {
                  return const Center(child: Text('Post not found'));
                }

                return PostWidget(
                  postId: post.id.toString(),
                  username: post.user.username,
                  location: "Location",
                  date: post.createdAt.toString(),
                  caption: post.post,
                  mediaUrls: post.media
                      .map((media) => "${ApiURLs.baseUrl.replaceAll("/api/", '')}${media.file}")
                      .toList(),
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
                );
              },
            );
          }
        },
      ),
    );
  }
}
