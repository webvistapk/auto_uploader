import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraVideoPlayer extends StatefulWidget {
  final String videoPath;

  CameraVideoPlayer({
    Key? key,
    required this.videoPath,
  }) : super(key: key);

  @override
  _CameraVideoPlayerState createState() => _CameraVideoPlayerState();
}

class _CameraVideoPlayerState extends State<CameraVideoPlayer> {
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    debugger();
    log("VideoPath : ${widget.videoPath}");
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      }).catchError((e) {
        debugger();
        log("Error: ${e.toString()}");
      });
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: _videoPlayerController!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                )
              : CircularProgressIndicator.adaptive(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _videoPlayerController!.value.isPlaying
                ? _videoPlayerController!.pause()
                : _videoPlayerController!.play();
          });
        },
        child: Icon(
          _videoPlayerController!.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ),
    );
  }
}
