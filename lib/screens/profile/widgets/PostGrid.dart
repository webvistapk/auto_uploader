import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/screens/profile/widgets/ReelPostGrid.dart';
import 'package:video_player/video_player.dart';
import '../../../models/UserProfile/post_model.dart';
import '../user_post_screen.dart';

class PostGrid extends StatelessWidget {
  final List<PostModel> posts;
  final bool isVideo;
  String filterType;
  String userId;

  PostGrid({
    super.key,
    required this.posts,
    this.isVideo = false,
    required this.filterType,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        return GestureDetector(
          onTap: post.media.isNotEmpty && post.media[0].mediaType == 'video'
              ? () {
                  // Navigate to full-screen video player
                  Navigator.push(
                    context,
                    CupertinoDialogRoute(
                      builder: (_) => FullscreenVideoPlayer(
                        videoUrl:
                            "http://147.79.117.253:8001${post.media[0].file}",
                      ),
                      context: context,
                    ),
                  );
                }
              : () {
                  // Navigate to PostScreen on tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPostScreen(
                        posts: posts,
                        initialIndex: index,
                        filterType: "all", // Update based on your context
                        userId: "userId", // Replace with actual userId
                      ),
                    ),
                  );
                },
          child: Hero(
            tag: 'profile_images_$index',
            child: Container(
              color: Colors.grey[300], // Grey background for shimmer effect
              child: post.media.isEmpty
                  ? Center(child: CircularProgressIndicator.adaptive())
                  : post.media[0].mediaType == 'video'
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayerWidget(
                              videoUrl:
                                  "http://147.79.117.253:8001${post.media[0].file}",
                            ),
                            Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 50,
                            ), // Play button overlay
                          ],
                        )
                      : Image.network(
                          "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.media[0].file}",
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image),
                        ),
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
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.isInitialized
              ? _controller.value.aspectRatio
              : 16 / 9,
          child: VideoPlayer(_controller),
        ),
        if (!_controller.value.isInitialized)
          const CircularProgressIndicator(), // Show loading indicator
      ],
    );
  }
}
