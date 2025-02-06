import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/screens/profile/imageFullScreen.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:mobile/screens/profile/widgets/ReelPostGrid.dart';
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
    try {
      List<PostModel> newPosts =
          await Provider.of<PostProvider>(context, listen: false)
              .getPost(context, widget.userId, limit, offset);

      setState(() {
        // Add only unique posts
        final newPostIds = _allPosts.map((post) => post.id).toSet();
        final uniquePosts =
            newPosts.where((post) => !newPostIds.contains(post.id)).toList();
        _allPosts.addAll(uniquePosts);
        offset += limit; // Increment offset for the next page of posts
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      print("Error fetching posts: $e");
    }
  }

  List<PostModel> _getFilteredPosts(List<PostModel> posts) {
    if (widget.filterType == "image") {
      return posts
          .where(
              (post) => post.media.any((media) => media.mediaType == 'image'))
          .toList();
    } else if (widget.filterType == "video") {
      return posts
          .where(
              (post) => post.media.any((media) => media.mediaType == 'video'))
          .toList();
    }
    return posts;
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

  void _deletePost(String postId) {
    setState(() {
      // Remove the post from the list
      _allPosts.removeWhere((post) => post.id.toString() == postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("UI Rebuild");
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
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              final filteredPosts = _getFilteredPosts(widget.posts);
              return ListView.builder(
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
          
                  var mediaList = post.media.isNotEmpty
                      ? post.media.map((media) => "${media.file}").toList()
                      : [""];
          
                  return SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(bottom: 4),
                      child: PostWidget(
                        isInteractive: true,
                        postId: post.id.toString(),
                        username: post.user.username.toString(),
                        location: "Location",
                        date: post.createdAt.toString(),
                        caption: post.post.toString(),
                        mediaUrls: post.media.isNotEmpty
                            ? post.media
                                .map((media) => "${media.file}")
                                .toList()
                            : [],
                        profileImageUrl: post.user.profileImage != null
                            ? "${post.user.profileImage}"
                            : AppUtils.userImage,
                        isVideo: post.media.isNotEmpty &&
                            post.media[0].mediaType == 'video',
                        likes: post.likesCount.toString(),
                        comments: post.commentsCount.toString(),
                        shares: "100",
                        saved: '100',
                        showCommentSection: false,
                        refresh: () => _deletePost(post.id.toString()),
                        isUserPost: true,
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
                                  builder: (context) => SinglePost(
                                      postId: post.id.toString(),
                                      onPostUpdated: () => _fetchPosts()),
                                ));
                          }
                        },
                        onPressLiked: () async {
                          // Check if post is already liked or not
                          if (post.isLiked) {
                            await postProvider.userDisLikes(
                              post.id,
                              context,
                            );
                            setState(() {
                              post.likesCount--;
                              post.isLiked = false;
                            });
                          } else {
                            await postProvider.newLikes(post.id, context);
                            setState(() {
                              post.likesCount++;
                              post.isLiked = true;
                            });
                          }
                        },
                        isLiked: post.isLiked,
                        postModel: post,
                        postTitle: post.pollTitle,
                                    postDescription: post.postDescription
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
