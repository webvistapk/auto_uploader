import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerFile extends StatefulWidget {
  final File file;

  const VideoPlayerFile({Key? key, required this.file}) : super(key: key);

  @override
  _VideoPlayerFileState createState() => _VideoPlayerFileState();
}

class _VideoPlayerFileState extends State<VideoPlayerFile> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.file(widget.file);
    await _controller.initialize();
    setState(() {});
    _controller.setLooping(true); // Optional: Enable looping
    _controller.play(); // Optional: Start playing automatically
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
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_controller),
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.blue,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.black,
                  ),
                ),
                _buildPlayPauseButton(),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.black54,
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
