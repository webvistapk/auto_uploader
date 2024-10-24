import 'package:flutter/material.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:video_player/video_player.dart';
import '../../../models/UserProfile/post_model.dart';
import '../post_screen.dart';
import '../user_post_screen.dart';

class PostGrid extends StatelessWidget {
  final List<PostModel> posts; // List of posts
  final String filterType; // Filter type (all, images, videos)

  PostGrid({
    Key? key,
    required this.posts,
    required this.filterType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Collect all media from all posts into a single list
    List<Media> allMedia = [];
    for (var post in posts) {
      allMedia.addAll(post.media);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: allMedia.length, // Number of total media files
      itemBuilder: (context, index) {
        final media = allMedia[index]; // Access the specific media file

        return GestureDetector(
          onTap: () {
            // Navigate to UserPostScreen on tap (optionally handle media details)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserPostScreen(
                  posts: posts,
                  initialIndex: index ~/ posts.first.media.length, // Map media index to post index
                  filterType: filterType,
                ),
              ),
            );
          },
          child: Hero(
            tag: 'profile_media_$index',
            child: media.mediaType == 'video'
                ? Container(
                width: double.infinity,
                height: 400,
                child: VideoPlayerWidget(
                    videoUrl:
                    "${ApiURLs.baseUrl.replaceAll("/api/", '')}${media.file}"))
                : Image.network(
              "${ApiURLs.baseUrl.replaceAll("/api/", '')}${media.file}",
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  // Image has fully loaded
                  return child;
                } else {
                  // Image is still loading, show CircularProgressIndicator
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                }
              },
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
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
    return Stack(
      alignment: Alignment.center, // Center the CircularProgressIndicator
      children: [
        AspectRatio(
          aspectRatio: _controller.value.isInitialized
              ? _controller.value.aspectRatio
              : 16 / 9, // Placeholder aspect ratio while loading
          child: VideoPlayer(_controller),
        ),
        if (!_controller.value.isInitialized)
          const CircularProgressIndicator(), // Show loading indicator
      ],
    );
  }
}