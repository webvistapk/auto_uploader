import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class ReelsVideoPlayer extends StatefulWidget {
  final File? videoFile;

  const ReelsVideoPlayer({Key? key, required this.videoFile}) : super(key: key);

  @override
  _ReelsVideoPlayerState createState() => _ReelsVideoPlayerState();
}

class _ReelsVideoPlayerState extends State<ReelsVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoController(widget.videoFile);
  }

  @override
  void didUpdateWidget(covariant ReelsVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoFile?.path != widget.videoFile?.path) {
      _initializeVideoController(widget.videoFile);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initializeVideoController(File? file) {
    // Dispose the previous controller if it exists
    _controller?.dispose();
    _isVideoReady = false;

    if (file != null && file.path.endsWith('.mp4')) {
      _controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {
            _isVideoReady = true; // Video is ready
          });
        }).catchError((error) {
          debugPrint('Error initializing video: ${file.path}, Error: $error');
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (widget.videoFile == null) {
      return Center(
        child: Text(
          "No Selected Reel Found!",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return _isVideoReady && _controller != null
        ? buildVideoPlayer()
        : Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              height: size.height * 0.4,
              width: size.width * 0.7,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
  }

  Widget buildVideoPlayer() {
    final controller = _controller;

    if (controller != null && controller.value.isInitialized) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * .35,
            margin: EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          VideoProgressIndicator(controller, allowScrubbing: true),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                });
              },
              child: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
