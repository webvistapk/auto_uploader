import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:provider/provider.dart';

import '../../common/utils.dart';
import '../../controller/endpoints.dart';

class SinglePost extends StatefulWidget {
  String postId;
   SinglePost({
     super.key,
    required this.postId
   });

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPost();
  }

  void fetchPost(){
    Provider.of<PostProvider>(context, listen: false).getSinglePost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              if (postProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (postProvider.post == null) {
                return const Center(child: Text('Post not found'));
              } else {
                final post = postProvider.post!;
                return PostWidget(
                  isTrue: false,
                  postId: post.id.toString(),
                  username: post.user.username.toString(),
                  location: "Location",
                  date: post.createdAt.toString(),
                  caption: post.post.toString(),
                  mediaUrls:post.media.map((media) => "${ApiURLs.baseUrl.replaceAll("/api/", '')}${media.file}").toList(),
                  profileImageUrl: AppUtils.testImage,
                  isVideo: post.media[0].mediaType,
                  likes: post.likesCount.toString(),
                  comments: post.commentsCount.toString(),
                  shares: "100",
                  saved: '100',
                  refresh: (){}, // Use the refresh function
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
