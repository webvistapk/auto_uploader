import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/profile/widgets/single_post.dart';
import 'package:provider/provider.dart';

import '../../controller/services/post/post_provider.dart';

class UserPostScreen extends StatefulWidget {
  final List<PostModel> posts;
  final int initialIndex;
  final String filterType;

  const UserPostScreen({
    Key? key,
    required this.posts,
    required this.initialIndex,
    required this.filterType,
  }) : super(key: key);

  @override
  State<UserPostScreen> createState() => _UserPostScreenState();
}

class _UserPostScreenState extends State<UserPostScreen> {
  late PageController _pageController;
  late List<PostModel> _posts;
  bool _isFirstLoad = true; // Track if it's the first time loading the screen

  Future<List<PostModel>>? _newposts;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _fetchPosts();

  }

 Future<void> _fetchPosts() async {
    // images and videos fetch and simulated from an API
    setState(() {
      _newposts=Provider.of<PostProvider>(context,listen: false).getPost(context);
    });
  }



  List<PostModel> getImagePosts(List<PostModel> posts) {
  return posts.where((post) {
  return post.media[0].mediaType == 'image';
  }).toList();

  }

  // Filter Video Posts
  List<PostModel> getVideoPosts(List<PostModel> posts) {
  return posts.where((post) {
  return post.media[0].mediaType == 'video';
  }).toList();
  }

  Future<void> DeletePost(String postID)async{
    Provider.of<PostProvider>(context,listen: false).deletePost(postID, context);
    _fetchPosts();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Details"),
      ),
      body:
      FutureBuilder<List<PostModel>>(
        future: _newposts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading state
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading posts")); // Error state
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts available")); // Empty state
          }

          // Data is ready
          List<PostModel> allPosts = snapshot.data!;

          // Apply filtering based on the filterType
          List<PostModel> filteredPosts;
          if (widget.filterType == 'image') {
            filteredPosts = getImagePosts(allPosts); // Filter for image posts
          } else if (widget.filterType == 'video') {
            filteredPosts = getVideoPosts(allPosts); // Filter for video posts
          } else {
            filteredPosts = allPosts; // Show all posts if no specific filter
          }

          if (filteredPosts.isEmpty) {
            return const Center(child: Text("No posts available for this filter"));
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
                      mediaUrl: post.media.isNotEmpty
                          ? "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.media[0].file}"
                          : '',
                      profileImageUrl: AppUtils.testImage,
                      isVideo: post.media[0].mediaType,
                      likes: '100',
                      comments: '100',
                      shares: "100",
                      saved: '100',
                      refresh: (){
                        DeletePost(post.id.toString());
                      }, // Use the refresh function
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
