import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io' as io; // To check platform

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
    print("REEL URL: ${widget.videoUrl}");
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

class XStreamChannelStreamScreen extends StatefulWidget {
  final streamID;

  XStreamChannelStreamScreen({required this.streamID});

  @override
  _XStreamChannelStreamScreenState createState() =>
      _XStreamChannelStreamScreenState();
}

class _XStreamChannelStreamScreenState
    extends State<XStreamChannelStreamScreen> {
  VideoPlayerController? _androidController;
  var _windowsController;
  bool _isInitialized = false;
  final bool _isWindows = io.Platform.isWindows;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (!_isWindows) {
        // Android-specific configuration
        _androidController = VideoPlayerController.network(
            'http://147.79.117.253:8001/media/reels/VID-20241104-WA0025_YbFuAeJ.mp4');
        await _androidController!.initialize();
        if (_androidController!.value.isInitialized) {
          _androidController!.play();
        }
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _androidController?.dispose();
    _windowsController?.dispose();
    super.dispose();
  }

  void _seekForward() {
    if (_isInitialized) {
      final position = _isWindows
          ? _windowsController!.value.position
          : _androidController!.value.position;
      final newPosition = position + Duration(seconds: 10);
      _isWindows
          ? _windowsController!.seekTo(newPosition)
          : _androidController!.seekTo(newPosition);
    }
  }

  void _seekBackward() {
    if (_isInitialized) {
      final position = _isWindows
          ? _windowsController!.value.position
          : _androidController!.value.position;
      final newPosition = position - Duration(seconds: 10);
      _isWindows
          ? _windowsController!.seekTo(newPosition)
          : _androidController!.seekTo(newPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          _isInitialized
                              ? Center(
                                  child: AspectRatio(
                                    aspectRatio: _isWindows
                                        ? _windowsController!.value.aspectRatio
                                        : _androidController!.value.aspectRatio,
                                    child: VideoPlayer(_androidController!),
                                  ),
                                )
                              : const Center(
                                  child:
                                      CircularProgressIndicator()), // Show a loader while initializing
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.fast_rewind,
                                        color: Colors.white),
                                    onPressed:
                                        _isInitialized ? _seekBackward : null,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      (_isInitialized &&
                                              (_isWindows
                                                  ? _windowsController!
                                                      .value.isPlaying
                                                  : _androidController!
                                                      .value.isPlaying))
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: _isInitialized
                                        ? () {
                                            setState(() {
                                              if (_isWindows) {
                                                _windowsController!
                                                        .value.isPlaying
                                                    ? _windowsController!
                                                        .pause()
                                                    : _windowsController!
                                                        .play();
                                              } else {
                                                _androidController!
                                                        .value.isPlaying
                                                    ? _androidController!
                                                        .pause()
                                                    : _androidController!
                                                        .play();
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.fast_forward,
                                        color: Colors.white),
                                    onPressed:
                                        _isInitialized ? _seekForward : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
