import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Future<List<PostModel>>? _posts;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  _fetchPost() {
    setState(() {
      _posts =
          Provider.of<PostProvider>(context, listen: false).getPost(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Posts")),
      body: FutureBuilder<List<PostModel>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Post is caalled ${snapshot.data}");
            print(
                "FutureBuilder snapshot: ${snapshot.connectionState}, ${snapshot.data}");
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final posts = snapshot.data; // Ensure posts is correctly accessed
            if (posts!.isNotEmpty) {
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostWidget(
                    username: post.user.username.toString(),
                    location: "Location",
                    date: post.createdAt.toString(),
                    caption: post.post.toString(),
                    mediaUrl: post.media.isNotEmpty
                        ? post.media[index].file
                        : '', // Check for media existence
                    profileImageUrl:
                        AppUtils.testImage, // Example profile image
                    isVideo: post.media.isNotEmpty
                        ? post.media[index].mediaType.toString()
                        : '', // Check for media existence
                    likes: '100',
                    comments: '100',
                    shares: "100",
                    saved: '100',
                    postId: '',
                    refresh: () {  },
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
    );
  }
}
