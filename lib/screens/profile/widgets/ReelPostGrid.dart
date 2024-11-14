import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/ReelPostModel.dart';
import 'package:mobile/screens/profile/ReelScreen.dart';
import 'package:mobile/video_stream_screen.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../controller/services/post/post_provider.dart';
import '../../../models/UserProfile/post_model.dart';

class ReelPostGrid extends StatefulWidget {
  final String userId;

  const ReelPostGrid({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _ReelPostGridState createState() => _ReelPostGridState();
}

class _ReelPostGridState extends State<ReelPostGrid> {
  List<ReelPostModel> _reel = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();
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
        _reel.addAll(newReel);
        offset += limit;

        if (newReel.length < limit) {
          _hasMore = false;
        }
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
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _reel.length,
            itemBuilder: (context, index) {
              final reels = _reel[index];
              print(reels);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReelScreen(
                        reels: _reel,
                        initialIndex: index,
                        showEditDeleteOptions: true,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'profile_images_$index',
                  child: VideoStreamScreen(
                      videoUrl: "http://147.79.117.253:8001${reels.file[0]}"),
                ),
              );
            },
          ),
        ),
        if (_hasMore)
          _isLoadingMore
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    elevation: MaterialStateProperty.all(0),
                  ),
                  onPressed: _fetchReelPosts,
                  child: Text("Load More"),
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
  bool _isBuffering = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
        setState(() {
          _isBuffering = _controller.value.isBuffering;
        });
      })
      ..initialize().then((_) {
        setState(() {
          _isBuffering = false;
        });
      });
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
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
        if (_isBuffering || !_controller.value.isInitialized)
          const CircularProgressIndicator(),
        if (_controller.value.isInitialized)
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _togglePlayPause,
            ),
          ),
      ],
    );
  }
}
