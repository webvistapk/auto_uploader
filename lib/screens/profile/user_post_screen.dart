import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:provider/provider.dart';

class UserPostScreen extends StatefulWidget {
  final List<PostModel> posts;
  final int initialIndex;
  final String filterType;
  final String userId;

  const UserPostScreen({
    Key? key,
    required this.posts,
    required this.initialIndex,
    required this.filterType,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserPostScreen> createState() => _UserPostScreenState();
}

class _UserPostScreenState extends State<UserPostScreen> {
  late PageController _pageController;
  Future<List<PostModel>>? _newposts;
  int limit = 10;   // Default limit of 10 posts per page
  int offset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _newposts = Provider.of<PostProvider>(context, listen: false)
          .getPost(context, widget.userId,limit,offset);
    });
  }

  List<PostModel> getImagePosts(List<PostModel> posts) {
    return posts.where((post) {
      return post.media.isNotEmpty && post.media[0].mediaType == 'image';
    }).toList();
  }

  List<PostModel> getVideoPosts(List<PostModel> posts) {
    return posts.where((post) {
      return post.media.isNotEmpty && post.media[0].mediaType == 'video';
    }).toList();
  }

  Future<void> DeletePost(String postID) async {
    Provider.of<PostProvider>(context, listen: false)
        .deletePost(postID, context);
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Details"),
      ),
      body: FutureBuilder<List<PostModel>>(
        future: _newposts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading posts"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts available"));
          }

          List<PostModel> allPosts = snapshot.data!;
          List<PostModel> filteredPosts;

          // Apply filtering based on the filterType
          if (widget.filterType == 'image') {
            filteredPosts = getImagePosts(allPosts);
          } else if (widget.filterType == 'video') {
            filteredPosts = getVideoPosts(allPosts);
          } else {
            filteredPosts = allPosts;
          }

          if (filteredPosts.isEmpty) {
            return const Center(
                child: Text("No posts available for this filter"));
          }

          return ListView.builder(
            controller: _pageController,
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostWidget(
                      postId: post.id.toString(),
                      username: post.user.username.toString(),
                      location: "Location",
                      date: post.createdAt.toString(),
                      caption: post.post.toString(),
                      mediaUrls: post.media.isNotEmpty
                          ? post.media
                              .map((media) =>
                                  "${ApiURLs.baseUrl.replaceAll("/api/", '')}${media.file}")
                              .toList()
                          : [], // Ensure empty list if no media
                      profileImageUrl: AppUtils.testImage,
                      isVideo: post.media.isNotEmpty
                          ? post.media[0].mediaType
                          : "image", // Check media availability
                      likes: post.likesCount.toString(),
                      comments: post.commentsCount.toString(),
                      shares: "100",
                      saved: '100',
                      refresh: () {
                        DeletePost(post.id.toString());
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
