import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import '../../../controller/endpoints.dart';
import '../../../controller/services/post/post_provider.dart';
import '../../../models/ReelPostModel.dart';

class ReelPostGrid extends StatefulWidget {
  final String userId;

  const ReelPostGrid({Key? key, required this.userId}) : super(key: key);

  @override
  _ReelPostGridState createState() => _ReelPostGridState();
}

class _ReelPostGridState extends State<ReelPostGrid> {
  List<String> _fileUrls = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  int limit = 9;
  int offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchReelPosts();
  }

  Future<void> _fetchReelPosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      List<ReelPostModel> newReel =
          await Provider.of<PostProvider>(context, listen: false)
              .fetchReels(context, widget.userId, limit, offset);

      setState(() {
        _fileUrls.addAll(
            newReel.map((reel) => '${ApiURLs.baseUrl2}${reel.file}').toList());
        offset += limit;
        if (newReel.length < limit) _hasMore = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reels: $error')),
      );
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchReelPosts();
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
          child: _fileUrls.isNotEmpty
              ? VideoGrid(
                  videoUrls: _fileUrls, scrollController: _scrollController)
              : const Center(child: Text("No reels available")),
        ),
        if (_isLoadingMore)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 40,
                width: double.infinity,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}

class VideoGrid extends StatefulWidget {
  final List<String> videoUrls;
  final ScrollController scrollController;

  const VideoGrid({required this.videoUrls, required this.scrollController});

  @override
  _VideoGridState createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  late List<VideoPlayerController> _controllers;
  int? _currentlyPlayingIndex;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = widget.videoUrls
        .map((url) => VideoPlayerController.network(url))
        .toList();
    for (var controller in _controllers) {
      controller.initialize().then((_) {
        setState(() {});
      }).catchError((error) {
        print("Error loading video: $error");
      });
    }
  }

  void _togglePlayPause(int index) {
    setState(() {
      if (_currentlyPlayingIndex == index &&
          _controllers[index].value.isPlaying) {
        _controllers[index].pause();
        _currentlyPlayingIndex = null;
      } else {
        if (_currentlyPlayingIndex != null) {
          _controllers[_currentlyPlayingIndex!].pause();
        }
        _controllers[index].play();
        _currentlyPlayingIndex = index;
      }
    });
  }

  void _openFullscreenVideo(String videoUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FullscreenVideoPlayer(videoUrl: videoUrl),
    ));
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return GridView.builder(
      controller: widget.scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: widget.videoUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _openFullscreenVideo(widget.videoUrls[index]);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: _controllers[index].value.isInitialized
                      ? _controllers[index].value.aspectRatio
                      : 16 / 9,
                  child: _controllers[index].value.isInitialized
                      ? VideoPlayer(_controllers[index])
                      : Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.grey),
                        ),
                ),
                if (_currentlyPlayingIndex != index ||
                    !_controllers[index].value.isPlaying)
                  Center(
                    child: Icon(
                      Icons.play_circle,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullscreenVideoPlayer({required this.videoUrl});

  @override
  _FullscreenVideoPlayerState createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {}); // Rebuild to show video once initialized
        _controller.play();
      })
      ..addListener(_videoProgressListener); // Listen to video progress

    // Auto navigate back when video completes
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(
        _videoProgressListener); // Remove listener to avoid memory leaks
    _controller.dispose();
    super.dispose();
  }

  void _videoProgressListener() {
    setState(() {}); // Rebuild widget to update the progress bar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player with tap-to-play/pause functionality
          GestureDetector(
            onTap: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            child: Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(), // Show loader while initializing
            ),
          ),
          // Top back button
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          // Top progress bar
          if (_controller.value.isInitialized)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _controller.value.position.inSeconds /
                    _controller.value.duration.inSeconds,
                backgroundColor: Colors.grey.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}
