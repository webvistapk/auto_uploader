import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/post/create_post_screen.dart';
import 'package:mobile/screens/post/post_reels.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:video_player/video_player.dart';

import '../../../models/UserProfile/userprofile.dart';

class AddPostCameraScreen extends StatefulWidget {
  final String token;
  final UserProfile userProfile;
  const AddPostCameraScreen(
      {Key? key, required this.token, required this.userProfile})
      : super(key: key);

  @override
  State<AddPostCameraScreen> createState() => _AddPostCameraScreenState();
}

class _AddPostCameraScreenState extends State<AddPostCameraScreen>
    with WidgetsBindingObserver {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedFile;
  bool _isVideo = false;
  bool _isRecording = false;
  Timer? _progressTimer;
  double _progress = 0.0;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoPlayerController = null;

    _chewieController?.dispose(); // Dispose chewie properly
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressTimer?.cancel();
    _videoPlayerController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.low);

    _initializeControllerFuture = _controller.initialize();

    if (mounted) setState(() {});
  }

  Future<String> _getFilePath(String ext) async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.$ext';
  }

  Future<void> _onTap() async {
    if (_isRecording) return; // Prevent tap while recording
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      _clearVideoController();

      setState(() {
        _capturedFile = image;
        _isVideo = false;
      });
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _onLongPressStart() async {
    if (_isRecording) return;
    try {
      await _initializeControllerFuture;
      await _controller.startVideoRecording();

      // Reset progress and timer
      _progress = 0.0;
      _recordingDuration = Duration.zero;

      _progressTimer =
          Timer.periodic(const Duration(milliseconds: 50), (timer) {
        setState(() {
          // Progress spinner infinite loop
          _progress += 0.02;
          if (_progress > 1) _progress = 0;
        });
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
        print('Recording timer: $_recordingDuration');
      });

      setState(() {
        _isRecording = true;
        _capturedFile = null;
        _isVideo = false;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _onLongPressEnd() async {
    if (!_isRecording) return;
    try {
      final video = await _controller.stopVideoRecording();

      _progressTimer?.cancel();
      _progressTimer = null;

      _recordingTimer?.cancel();
      _recordingTimer = null;

      // Dispose previous controllers
      await _chewieController?.pause();
      _chewieController?.dispose();
      _chewieController = null;

      await _videoPlayerController?.pause();
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;

      final file = File(video.path);

      // Give time for file to flush
      await Future.delayed(const Duration(milliseconds: 300));

      final newVideoController = VideoPlayerController.file(file);
      await newVideoController.initialize();

      if (!mounted) return;

      // Setup ChewieController
      _chewieController = ChewieController(
        videoPlayerController: newVideoController,
        autoPlay: true,
        looping: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          bufferedColor: Colors.white70,
          backgroundColor: Colors.white30,
        ),
        placeholder: Container(
          color: Colors.black,
        ),
      );

      setState(() {
        _videoPlayerController = newVideoController;
        _capturedFile = video;
        _isRecording = false;
        _isVideo = true;
        _progress = 0.0;
        _recordingDuration = Duration.zero;
      });
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _clearVideoController() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.pause();
      _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }
  }

  void _reset() {
    _clearVideoController();
    setState(() {
      _capturedFile = null;
      _isVideo = false;
      _progress = 0.0;
    });
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _onTap,
      onLongPressStart: (_) => _onLongPressStart(),
      onLongPressEnd: (_) => _onLongPressEnd(),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isRecording ? 1.1 : 1.0,
        curve: Curves.easeInOut,
        child: _isRecording
            ? CircularPercentIndicator(
                radius: 42.0,
                lineWidth: 6.0,
                percent: _progress,
                progressColor: Colors.redAccent,
                backgroundColor: Colors.red.withOpacity(0.3),
                circularStrokeCap: CircularStrokeCap.round,
                center: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.7),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              )
            : Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.grey.shade300,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      blurRadius: 2,
                      spreadRadius: 1,
                      offset: const Offset(0, -2),
                      // inset:
                      //     true, // inner shadow for depth — requires flutter 3.7+
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.black54, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPreviewOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_capturedFile != null)
              Positioned.fill(
                child: _isVideo
                    ? (_chewieController != null &&
                            _chewieController!
                                .videoPlayerController.value.isInitialized
                        ? Chewie(controller: _chewieController!)
                        : const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ))
                    : Image.file(File(_capturedFile!.path), fit: BoxFit.cover),
              ),
            Positioned(
              bottom: 80,
              child: Column(
                children: [
                  if (_isRecording)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _formatDuration(_recordingDuration),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 40, color: Colors.white),
                        onPressed: _reset,
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        icon: const Icon(Icons.check,
                            size: 40, color: Colors.greenAccent),
                        onPressed: () {
                          print("Confirmed");
                          // Your confirm logic here
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isRecording)
              Positioned(
                bottom: 20,
                child: CircularPercentIndicator(
                  radius: 36.0,
                  lineWidth: 5.0,
                  percent: _progress,
                  progressColor: Colors.red,
                  backgroundColor: Colors.white.withOpacity(0.4),
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      color: Color(0xfa1B1C1C),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () async {
              if (!mounted) return;

              // Now navigate
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreatePostScreen(
                    userProfile: widget.userProfile,
                    token: widget.token,
                  ),
                ),
              );
            },
            child: const Text("Upload", style: TextStyle(color: Colors.white)),
          ),
          const Text("Drafts", style: TextStyle(color: Colors.white)),
          const Icon(Icons.circle, size: 20, color: Colors.white),
          const Text("Camera",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Text("Write", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cameraHeight = screenHeight * 0.9; // 90% for camera
    final bottomHeight = screenHeight * 0.1; // 10% for bottom controls

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: SizedBox(
        height: bottomHeight,
        child: _buildBottomNav(),
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  height: cameraHeight,
                  width: double.infinity,
                  child: CameraPreview(_controller),
                );
              } else {
                return SizedBox(
                  height: cameraHeight,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
          if (_capturedFile != null)
            SizedBox(
              height: cameraHeight,
              width: double.infinity,
              child: _buildPreviewOverlay(),
            ),
          Positioned(
            bottom: 10, // above bottom nav
            left: 0,
            right: 0,
            child: Center(
              child: _capturedFile == null
                  ? _buildCaptureButton()
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
