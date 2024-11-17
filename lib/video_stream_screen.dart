import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoStreamScreen extends StatefulWidget {
  final String videoUrl;
  final VoidCallback? onVideoPlayed; // Callback to notify that video is played

  const VideoStreamScreen({
    Key? key,
    required this.videoUrl,
    this.onVideoPlayed,
  }) : super(key: key);

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
      ..initialize().then((_) async {
        setState(() {
          _isLoading = false;
        });
        if (widget.onVideoPlayed != null) {
          widget.onVideoPlayed!(); // Notify that video is played
        }
        await _videoController.setLooping(true);
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
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          if (!_videoController.value.isPlaying) {
            _videoController.play();
            setState(() {
              _isPlaying = true;
            });
          }
        } else {
          if (_videoController.value.isPlaying) {
            _videoController.pause();
            setState(() {
              _isPlaying = false;
            });
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          ),
          GestureDetector(
            onTap: _togglePlayPause,
          ),
          if (!_isPlaying)
            GestureDetector(
              onTap: _togglePlayPause,
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white.withOpacity(0.8),
                size: 60,
              ),
            ),
        ],
      ),
    );
  }
}
