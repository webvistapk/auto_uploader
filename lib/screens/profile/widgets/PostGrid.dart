import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  const PostGrid({
    Key? key,
    required this.posts,
    this.isVideo = false,
    required this.filterType,
    required this.userId,
  }) : super(key: key);

  @override
  _PostGridState createState() => _PostGridState();
}

class _PostGridState extends State<PostGrid> {
  List<PostModel> _posts = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();
  int limit = 9;
  int offset = 0;

  @override
  void initState() {
    super.initState();
    _posts = widget.posts;
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchPosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      List<PostModel> newPosts = await Provider.of<PostProvider>(context, listen: false)
          .getPost(context, widget.userId, limit.toString(), offset.toString());

      setState(() {
        _posts.addAll(newPosts);
        offset += limit;

        if (newPosts.length < limit) {
          _hasMore = false;
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load posts: $error')),
      );
    } finally {
      //await Future.delayed(Duration(seconds: 2));
      setState(() {
        _isLoadingMore = false;
      });
    }
  }
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300 && !_isLoadingMore && _hasMore) {
      _fetchPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _posts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPostScreen(
                        posts: _posts,
                        initialIndex: index,
                        filterType: widget.filterType,
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'profile_images_$index',
                  child: post.media[0].mediaType == 'video'
                      ? VideoPlayerWidget(videoUrl: "http://147.79.117.253:8001/api${post.media[0].file}")
                      : Image.network(
                    post.media.isNotEmpty
                        ? "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.media[0].file}"
                        : '',
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
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
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
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
          const CircularProgressIndicator(),
      ],
    );
  }
}
