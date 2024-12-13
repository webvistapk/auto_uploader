import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/screens/messaging/widgets/media_display_message.dart';
import 'package:video_player/video_player.dart';

class MessageVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const MessageVideoPlayer({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  _MessageVideoPlayerState createState() => _MessageVideoPlayerState();
}

class _MessageVideoPlayerState extends State<MessageVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isError = false;
  String url = '';
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (!widget.videoUrl.contains(ApiURLs.baseUrl2)) {
        url = ApiURLs.baseUrl2 + widget.videoUrl;
        if (mounted) setState(() {});
      }
      _controller = VideoPlayerController.network(url);
      await _controller.initialize();
      setState(() {
        _isError = false;
      });
    } catch (e) {
      debugPrint("Video initialization error: $e");
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Center(
        child: Text("Failed to load video."),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (_controller.value.isInitialized)
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width * .6,
            child: AspectRatio(
              aspectRatio: .9,
              child: VideoPlayer(_controller),
            ),
          )
        else
          _buildLoadingThumbnail(),
        // Play Icon
        if (_controller.value.isInitialized)
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoDialogRoute(
                      builder: (_) =>
                          MediaMessageDisplay(mediaUrl: widget.videoUrl),
                      context: context));
            },
            child: const Icon(
              Icons.play_circle_fill,
              size: 50,
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingThumbnail() {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width * 0.6,
      color: Colors.black,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
