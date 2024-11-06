import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/models/ReelPostModel.dart';
import 'package:mobile/screens/profile/ReelScreen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import '../../../controller/endpoints.dart';
import '../../../controller/services/post/post_provider.dart';
import '../../../models/UserProfile/post_model.dart';
import '../user_post_screen.dart';

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
  List<ReelPostModel> _reel= [];
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

    // Check if already loading more or if there's no more data to load
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true; // Set loading state
    });

    try {
      // Fetch new posts from the provider
      List<ReelPostModel> newReel= await Provider.of<PostProvider>(context, listen: false)
          .fetchReels(context, widget.userId, limit, offset); // Use int for limit and offset

      setState(() {
        _reel.addAll(newReel); // Add new posts to the existing list
        offset += limit; // Increment offset for the next fetch

        // If the number of new posts is less than the limit, set hasMore to false
        if (newReel.length < limit) {
          _hasMore = false;
        }
      });
    } catch (error) {
      // Show an error message in case of failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reels: $error')),
      );
    } finally {
      setState(() {
        _isLoadingMore = false; // Reset loading state
      });
    }
  }

  void _onScroll() {
    // Check if the user has scrolled near the bottom of the list
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchReelPosts(); // Call the fetch function
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
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReelScreen(
                        posts: _reel.map((reel) => reel.file).toList(), // List of URLs
                        initialIndex: index, // Start at the tapped index
                      ),
                    ),
                  );
                },
                child: Hero(
                    tag: 'profile_images_$index',
                    child: VideoPlayerWidget(videoUrl: "http://147.79.117.253:8001/api${reels.file[0]}")

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
              onPressed: _isLoadingMore ? null : _fetchReelPosts,
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
        if (_isBuffering || !_controller.value.isInitialized)
          Center(
            child: Container(
              width: 40, // Adjust the size for YouTube-like spinner
              height: 40,
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