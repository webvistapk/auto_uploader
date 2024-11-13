import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
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
  List<PostModel> _allPosts = [];
  bool _isLoadingMore = false;
  int limit = 10; // Default limit of 10 posts per page
  int offset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _allPosts = widget.posts; // Initialize with the provided posts
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoadingMore = true;
    });
    List<PostModel> newPosts =
        await Provider.of<PostProvider>(context, listen: false)
            .getPost(context, widget.userId, limit, offset);

    setState(() {
      _allPosts.addAll(newPosts);
      offset += limit; // Increment offset for the next page of posts
      _isLoadingMore = false;
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
      backgroundColor: AppColors.mainBgColor,
      appBar: AppBar(backgroundColor: AppColors.mainBgColor),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              !_isLoadingMore) {
            _fetchPosts(); // Load more posts when the user reaches the bottom
          }
          return false;
        },
        child: ListView.builder(
          controller: _pageController,
          itemCount: _allPosts.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _allPosts.length) {
              // Show loading indicator at the bottom if loading more posts
              return const Center(child: CircularProgressIndicator());
            }

            final post = _allPosts[index];

            // Filter posts based on the filterType
            List<PostModel> filteredPosts;
            if (widget.filterType == 'image') {
              filteredPosts = getImagePosts(_allPosts);
            } else if (widget.filterType == 'video') {
              filteredPosts = getVideoPosts(_allPosts);
            } else {
              filteredPosts = _allPosts;
            }

            if (filteredPosts.isEmpty) {
              return const Center(
                  child: Text("No posts available for this filter"));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostWidget(
                    isInteractive: true,
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
                    isVideo: post.media.isNotEmpty &&
                        post.media[0].mediaType == 'video',
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
