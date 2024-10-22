import 'package:flutter/material.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:video_player/video_player.dart';
import '../../../models/UserProfile/post_model.dart';
import '../post_screen.dart';
import '../user_post_screen.dart';

class PostGrid extends StatelessWidget {
  final List<PostModel> posts; // Future that fetches posts
  final bool isVideo;
  final Function(String postId) refresh;
  String filterType;


   PostGrid({
    super.key,
    required this.posts,
    this.isVideo = false,
    required this.refresh,
    required this.filterType,
  });

  @override
  Widget build(BuildContext context) {
    return  GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: posts.length, // Use the length of the post list
      itemBuilder: (context, index) {
        final post = posts[index]; // Access the specific post

        return GestureDetector(
          onTap: () {
            // Navigate to PostScreen on tap
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  UserPostScreen(
                    posts: posts,
                    initialIndex: index,
                    refresh:refresh,
                    filterType:filterType
                ),
              ),
            );
          },
          child: Hero(
            tag: 'profile_images_$index',
            child: post.media[0].mediaType=='video'?
            Container(
                width: double.infinity,
                height: 400,
                child: VideoPlayerWidget(videoUrl: "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.media[0].file}"))
                :
            Image.network(
              post.media.isNotEmpty ? "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.media[0].file}" : '', // Display the media URL
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image),
            ),
          ),
        );
      },
    );
  }
}


class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Auto-play the video
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Center(child: CircularProgressIndicator());
  }
}