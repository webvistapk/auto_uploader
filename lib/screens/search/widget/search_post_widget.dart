import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/screens/profile/imageFullScreen.dart';
import 'package:mobile/screens/profile/widgets/ReelPostGrid.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class SearchPostWidget extends StatefulWidget {
  final List<PostModel> posts;

  const SearchPostWidget({super.key, required this.posts});

  @override
  State<SearchPostWidget> createState() => _SearchPostWidgetState();
}

class _SearchPostWidgetState extends State<SearchPostWidget> {
  // Track video controllers to dispose them later
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};

  @override
  void dispose() {
    // Dispose all video controllers when widget is disposed
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleMediaTap(
    String postID,
  ) {
    Navigator.push(
        context,
        CupertinoDialogRoute(
            builder: (_) =>
                SinglePost(postId: postID, onPostUpdated: () {}),
            context: context));
  }

  @override
  Widget build(BuildContext context) {
    // Extract media items with their types from posts
    final mediaItems = <_MediaItem>[];
    for (var post in widget.posts) {
      for (var media in post.media) {
        mediaItems.add(_MediaItem(
            url: media.file,
            isVideo:
                media.mediaType == 'video', // Assuming media has a 'type' field
            id: post.id.toString()));
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mediaItems.length,
          itemBuilder: (context, index) {
            final media = mediaItems[index];

            if (media.isVideo) {
              return _buildVideoItem(media.url, index, media.id);
            } else {
              return _buildImageItem(media.url, media.id);
            }
          },
        ),
      ),
    );
  }

  Widget _buildImageItem(String url, id) {
    return GestureDetector(
      onTap: () {
        _handleMediaTap(id);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoItem(String url, int index, String id) {
    if (!_videoControllers.containsKey(index)) {
      _videoControllers[index] = VideoPlayerController.network(url)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoControllers[index]!.play();
            _chewieControllers[index] = ChewieController(
              videoPlayerController: _videoControllers[index]!,
              autoPlay: true,
              looping: true,
              showControls: false,
              allowFullScreen: false,
            );
          }
        });
    }

    return GestureDetector(
      onTap: () {
        _handleMediaTap(id);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: _videoControllers[index] != null &&
                  _videoControllers[index]!.value.isInitialized
              ? Chewie(controller: _chewieControllers[index]!)
              : Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
        ),
      ),
    );
  }
}

// Helper class to store media information
class _MediaItem {
  final String url;
  final bool isVideo;
  final String id;

  _MediaItem({required this.url, required this.isVideo, required this.id});
}
