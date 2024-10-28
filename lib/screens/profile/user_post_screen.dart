import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:provider/provider.dart';
import '../../controller/services/post/post_provider.dart';

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
  late ScrollController _scrollController;
  List<PostModel> _posts = [];
  int limit = 10; // Default limit
  int offset = 0; // Offset for pagination
  bool _isLoadingMore = false; // To track if more posts are being loaded
  bool _hasMore = true; // To track if there are more posts to load
  bool _isFirstLoad = true; // Track if it's the first time loading posts

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchPosts(); // Initial fetch for the first 10 posts
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch posts with pagination
  Future<void> _fetchPosts() async {
    if (_isLoadingMore || !_hasMore) return; // Prevent multiple calls if already loading or no more data

    setState(() {
      _isLoadingMore = true;
    });

    try {
      List<PostModel> newPosts = await Provider.of<PostProvider>(context, listen: false)
          .getPost(context, widget.userId, limit.toString(), offset.toString());

      setState(() {
        if (newPosts.length < limit) {
          _hasMore = false; // No more data available if the returned posts are less than the limit
        }
        _posts.addAll(newPosts); // Append new posts to the existing list
        offset += limit; // Increment the offset for pagination
        _isFirstLoad = false; // Mark first load as complete
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Detect when user scrolls to the bottom
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // When the user scrolls close to the bottom (200 pixels from the end), fetch more posts
      _fetchPosts();
    }
  }

  Future<void> deletePost(String postID) async {
    Provider.of<PostProvider>(context, listen: false).deletePost(postID, context);
    _fetchPosts(); // Reload posts after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
      ),
      body: _isFirstLoad
          ? const Center(child: CircularProgressIndicator()) // Initial loading state
          : ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + (_isLoadingMore ? 1 : 0), // Add 1 for the loading indicator
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            // Show CircularProgressIndicator at the bottom while loading more posts
            return const Center(child: CircularProgressIndicator());
          }

          final post = _posts[index];
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
                  mediaUrls: post.media
                      .map((media) =>
                  "${ApiURLs.baseUrl.replaceAll("/api/", '')}${media.file}")
                      .toList(),
                  profileImageUrl: AppUtils.testImage,
                  isVideo: post.media[0].mediaType,
                  likes: post.likes_count.toString(),
                  comments: post.commnets_count.toString(),
                  shares: "100",
                  saved: '100',
                  refresh: () {
                    deletePost(post.id.toString());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
