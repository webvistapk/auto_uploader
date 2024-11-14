import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoStreamScreen extends StatefulWidget {
  final String videoUrl;

  VideoStreamScreen({required this.videoUrl});

  @override
  _VideoStreamScreenState createState() => _VideoStreamScreenState();
}

class _VideoStreamScreenState extends State<VideoStreamScreen> {
  late VideoPlayerController _videoController;
  bool _isPlaying = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        print("Error loading video: $error");
        setState(() => _isLoading = false);
      });
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Video Stream"),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlayPause,
        child: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
