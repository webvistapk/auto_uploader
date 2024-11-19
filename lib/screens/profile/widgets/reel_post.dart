import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../video_stream_screen.dart';
 // Import the VideoStreamScreen

class ReelPost extends StatefulWidget {
  final String? src;
  const ReelPost({Key? key, required this.src}) : super(key: key);

  @override
  _ReelPostState createState() => _ReelPostState();
}

class _ReelPostState extends State<ReelPost> {
  @override
  void initState() {
    super.initState();
    print("SRC: ${widget.src}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: widget.src != null && widget.src!.isNotEmpty
            ? VideoStreamScreen(videoUrl: "http://147.79.117.253:8001${widget.src.toString()}") // Use VideoStreamScreen
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading...'),
          ],
        ),
      ),
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
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Center(child: CircularProgressIndicator());
  }
}


