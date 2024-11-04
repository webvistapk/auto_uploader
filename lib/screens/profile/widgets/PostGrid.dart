import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import '../../../controller/endpoints.dart';
import '../../../controller/services/post/post_provider.dart';
import '../../../models/UserProfile/post_model.dart';
import '../user_post_screen.dart';

class PostGrid extends StatefulWidget {
  final List<PostModel> posts;
  final bool isVideo;
  final String filterType;
  final String userId;

  PostGrid(
      {super.key,
      required this.posts,
      this.isVideo = false,
      required this.filterType,
      required this.userId});

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
      itemCount: posts.length, // Use the length of the post list
      itemBuilder: (context, index) {
        final post = posts[index]; // Access the specific post

        return GestureDetector(
          onTap: () {
            // Navigate to PostScreen on tap
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserPostScreen(
                  posts: posts,
                  initialIndex: index,
                  filterType: filterType,
                  userId: userId,
                ),
              ),
            );
          },
          child: Hero(
              tag: 'profile_images_$index',
              child: post.media[0].mediaType == 'video'
                  ? Container(
                      width: double.infinity,
                      height: 400,
                      child: VideoPlayerWidget(
                          videoUrl:
                              "http://147.79.117.253:8001/api${post.media[0].file}"))
                  : Image.network(
                      post.media.isNotEmpty
                          ? "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.media[0].file}"
                          : '', // Display the media URL
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
                            Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                                strokeWidth: 2.0, // Adjust the size of the progress indicator
                              ),
                            ),
                          ],
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image), // Fallback for error
                  ),
                ),
              );
            },
          ),
        ),
        if (_hasMore) // Show "Load More" button only if there are more posts
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent), // Transparent background
                elevation: MaterialStateProperty.all(0)
            ),
            onPressed: _isLoadingMore ? null : _fetchPosts,
            child: _isLoadingMore
                ? CircularProgressIndicator(
            ):Container()
          ),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;


  VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isBuffering = true;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
        setState(() {
          // Check if the video is buffering
          _isBuffering = _controller.value.isBuffering;
        });
      })
      ..initialize().then((_) {
        setState(() {
          _isBuffering = false; // Video initialized, stop buffering
        });
        _controller.play();
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
          const Center(
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: AppColors.blue,
            ),
          ),
        if (_isBuffering)
          Center(
            child: Container(
              width: 60, // Adjust the size for YouTube-like spinner
              height: 60,
              child: const CircularProgressIndicator(
                strokeWidth: 4.0,
                color: AppColors.blue, // White spinner for YouTube-like effect
              ),
            ),
          ),
      ],
    );
  }
}
