import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/screens/post/add_post_screen.dart';
import 'package:mobile/screens/post/create_post_screen.dart';
import 'package:mobile/screens/post/post_reels.dart';
import 'package:mobile/screens/post/view/camera/camera.dart';
import 'package:mobile/screens/post/view/camera/preview_screen.dart';
import 'package:mobile/utils/custom_navigations.dart';
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
  Future<void>? _initializeControllerFuture; // Make nullable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.ultraHigh);

    _initializeControllerFuture = _controller.initialize();

    // Rebuild UI after initialization future is assigned
    if (mounted) setState(() {});
  }

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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressTimer?.cancel();
    _recordingTimer?.cancel();
    _disposeVideoControllers();
    if (mounted) {
      _controller.dispose();
    }
    super.dispose();
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

      // Dispose old video controllers first if any
      await _disposeVideoControllers();

      await _controller.startVideoRecording();

      // Reset progress and timer
      _progress = 0.0;
      _recordingDuration = Duration.zero;

      _progressTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          _recordingDuration += const Duration(milliseconds: 100);
          // For example, max 15 seconds video
          final maxDuration = Duration(seconds: 15);
          _progress =
              _recordingDuration.inMilliseconds / maxDuration.inMilliseconds;
          if (_progress >= 1) {
            _progress = 1.0;
            _onLongPressEnd(); // Auto stop recording when max reached
            timer.cancel();
          }
        });
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 0), (timer) {
        setState(() {
          _recordingDuration += const Duration(seconds: 0);
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

      final file = File(video.path);

      // Wait until file is ready
      int retryCount = 0;
      while ((!file.existsSync() || file.lengthSync() == 0) && retryCount < 5) {
        await Future.delayed(const Duration(milliseconds: 300));
        retryCount++;
      }

      // Dispose existing video controllers before creating new one
      await _disposeVideoControllers();
      debugger();
      final newVideoController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          // Set looping and start playing

          setState(() {});
        });
      newVideoController.setLooping(true);
      newVideoController.play();
      setState(() {});
      if (!mounted) return;

      if (newVideoController.value.hasError) {
        log('Video player error: ${newVideoController.value.errorDescription}');
        return;
      }

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
        placeholder: Container(color: Colors.black),
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
      log('Error stopping video recording: $e');
      setState(() {
        _isRecording = false;
        _progress = 0.0;
        _recordingDuration = Duration.zero;
      });
    }
  }

  Future<void> _disposeVideoControllers() async {
    try {
      await _chewieController?.pause();
      _chewieController?.dispose();
      _chewieController = null;

      await _videoPlayerController?.pause();
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;
    } catch (e) {
      print('Error disposing video controllers: $e');
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isRecording ? 213.86.sp : 213.86.sp,
        height: _isRecording ? 177.54.sp : 177.54.sp,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isRecording
              ? null
              : LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: _isRecording ? Colors.transparent : null,
          boxShadow: _isRecording
              ? [
                  BoxShadow(
                    color: Color.fromRGBO(123, 123, 123, 1),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
        ),
        child: Center(
          child: _isRecording
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer gray border
                    Container(
                      width: 160.sp,
                      height: 160.sp,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(123, 123, 123, 1),
                      ),
                    ),

                    // Inner red circle
                    Container(
                      width: 130.sp,
                      height: 130.sp,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),

                    // White circular progress
                    CircularPercentIndicator(
                      radius: 85.sp,
                      lineWidth: 4.sp,
                      percent: _progress,
                      progressColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ],
                )
              : Container(
                  width: 161.32.sp,
                  height: 161.32.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black,
                      width: 3.sp,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // UPDATED: _buildPreviewOverlay with proper Stack parent for Positioned widgets
  Widget _buildPreviewOverlay() {
    return Stack(
      children: [
        Positioned.fill(
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
                            ? GestureDetector(
                                onTap: () {
                                  final controller =
                                      _chewieController!.videoPlayerController;
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                },
                                child: VideoPlayer(_videoPlayerController!),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ))
                        : Image.file(File(_capturedFile!.path),
                            fit: BoxFit.cover),
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
                          GestureDetector(
                              onTap: () {
                                if (_capturedFile != null) {
                                  // Create a list of files to pass (even if single file)
                                  final file = File(_capturedFile!.path);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddPostScreen(
                                        mediFiles: [file],
                                        userProfile: widget.userProfile,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('No media captured')),
                                  );
                                }
                              },
                              child: SizedBox(
                                width: 50,
                                height: 25,
                                child: Image.asset(
                                  "assets/icons/tick.png",
                                ),
                              )),
                          const SizedBox(width: 40),
                          ClipPath(
                            clipper: LeftArrowClipper(),
                            child: Material(
                              color: Colors.white,
                              child: InkWell(
                                onTap: _reset,
                                child: SizedBox(
                                  width: 50,
                                  height: 25,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Image.asset(
                                        "assets/icons/cross_post.png"),
                                  ),
                                ),
                              ),
                            ),
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
        ),
      ],
    );
  }

  // Add this at the top of your state class/
  int _selectedIndex = 2; // Default selected item (Camera)

  Widget _buildBottomNav() {
    return Container(
      height: 52.sp,
      color: Color(0xfa1B1C1C),
      padding: EdgeInsets.symmetric(horizontal: 39.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem("Upload", 0),
          _buildNavItem("Drafts", 1),
          _buildNavItem("Camera", 2),
          _buildNavItem("Write", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, int index) {
    final isSelected = index == _selectedIndex;

    return GestureDetector(
      onTap: () async {
        if (!mounted) return;

        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          final oldController = _controller;
          // _controller = null;
          setState(() {}); // Rebuild UI to remove CameraPreview

          // await oldController.dispose();

          await Future.delayed(Duration(milliseconds: 50)); // Let UI rebuild

          if (!mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(
                userProfile: widget.userProfile,
                token: widget.token,
              ),
            ),
          );
        }

        // Add other navigation cases as needed
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.publicSans(
              fontSize: 12,
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4.sp),
              height: 1,
              width: 20, // Width of the underline
              color: Colors.white,
            ),
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
      body:
          // Flexible(child: CustomCameraScreen())
          Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _controller.value.isInitialized) {
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

class LeftArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(20, 0); // Start after arrow tip
    path.lineTo(size.width, 0); // Top-right corner
    path.lineTo(size.width, size.height); // Bottom-right
    path.lineTo(20, size.height); // Bottom-left before arrow
    path.lineTo(0, size.height / 2); // Arrow tip
    path.lineTo(20, 0); // Top-left before arrow
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
