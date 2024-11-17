import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import '../../../controller/endpoints.dart';
import '../../../controller/services/post/post_provider.dart';
import '../../../models/ReelPostModel.dart';
import '../ReelScreen.dart';

class ReelPostGrid extends StatefulWidget {
  final String userId;

  const ReelPostGrid({Key? key, required this.userId}) : super(key: key);

  @override
  _ReelPostGridState createState() => _ReelPostGridState();
}

class _ReelPostGridState extends State<ReelPostGrid> {
  List<ReelPostModel> _reels = [];
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
        _reels.addAll(newReel);
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

  void _navigateToReelScreen(int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ReelScreen(
        reels: _reels,
        initialIndex: index, // Pass the index of the selected video
        showEditDeleteOptions: true,
      ),
    ));
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
            videoUrls: _fileUrls,
            scrollController: _scrollController,
            onVideoTap: _navigateToReelScreen, // Pass function to VideoGrid
          )
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
  final Function(int) onVideoTap;

  const VideoGrid({
    required this.videoUrls,
    required this.scrollController,
    required this.onVideoTap,
  });

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
      if (_currentlyPlayingIndex == index && _controllers[index].value.isPlaying) {
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
          onTap: () => widget.onVideoTap(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: VideoThumbnail(url: widget.videoUrls[index]),
          ),
        );
      },
    );
  }
}


/*class VideoGrid extends StatefulWidget {
  final List<String> videoUrls;
  final ScrollController scrollController;
  final Function(int) onVideoTap;

  const VideoGrid({
    required this.videoUrls,
    required this.scrollController,
    required this.onVideoTap,
  });

  @override
  State<VideoGrid> createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
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
          onTap: (){
            print("On Tapped");
            widget.onVideoTap;
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: VideoThumbnail(url: widget.videoUrls[index]),
          ),
        );
      },
    );
  }
}*/

class VideoThumbnail extends StatefulWidget {
  final String url;

  const VideoThumbnail({required this.url});

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
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
        ? Stack(
            children: [
              VideoPlayer(_controller),
              const Positioned.fill(
                child: Icon(Icons.play_circle, color: Colors.white, size: 50),
              ),
            ],
          )
        : Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.grey),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
