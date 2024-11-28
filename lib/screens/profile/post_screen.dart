import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:provider/provider.dart';

import '../../controller/endpoints.dart';

class PostScreen extends StatefulWidget {
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Future<List<PostModel>>? _posts;
  int limit = 10; // Default limit of 10 posts per page
  int offset = 0; // Offset for pagination

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  // Fetch posts with pagination (limit and offset)
  _fetchPost() {
    setState(() {
      _posts = Provider.of<PostProvider>(context, listen: false)
          .getPost(context, "", limit, offset);
    });
  }

  // Function to load the next page
  void _loadNextPage() {
    setState(() {
      offset += limit; // Increase the offset to fetch the next set of posts
      _fetchPost();
    });
  }

  // Function to load the previous page
  void _loadPreviousPage() {
    if (offset > 0) {
      setState(() {
        offset -=
            limit; // Decrease the offset to fetch the previous set of posts
        _fetchPost();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Posts")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<PostModel>>(
              future: _posts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('An error occurred: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final posts = snapshot.data!;
                  if (posts.isNotEmpty) {
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];

                        print(post);
                        // debugger();
                        return PostWidget(
                          username: post.user.username.toString(),
                          location: "Location",
                          date: post.createdAt.toString(),
                          caption: post.post.toString(),
                          mediaUrls:
                              post.media.map((media) => media.file).toList(),
                          isVideo: post.media.isNotEmpty &&
                              post.media[0].mediaType == 'video', // Fix here
                          profileImageUrl: post.user.profileImage != null
                              ? post.user.profileImage!
                                      .contains('http://147.79.117.253:8001')
                                  ? post.user.profileImage!
                                  : "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.user.profileImage}"
                              : AppUtils.userImage,
                          likes: '100',
                          comments: '100',
                          shares: "100",
                          saved: '100',
                          postId: '',
                          refresh: () {},
                          isUserPost: false,
                          isInteractive: true,
                          onPressed: () async {
                            final result = await Navigator.push(
                                context,
                                CupertinoDialogRoute(
                                    builder: (_) =>
                                        SinglePost(postId: post.id.toString()),
                                    context: context));

                            // Check if the result indicates a need to refresh
                            if (result == true) {
                              setState(() {
                                // Call the method to refresh the data
                                // _refreshData();
                              });
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No Post Yet"));
                  }
                } else {
                  return Center(child: Text("No Post Yet"));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: offset > 0
                      ? _loadPreviousPage
                      : null, // Disable if on the first page
                  child: Text("Previous"),
                ),
                ElevatedButton(
                  onPressed:
                      _loadNextPage, // Always allow Next unless there are no more posts
                  child: Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
