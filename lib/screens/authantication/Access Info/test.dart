import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(camera: camera),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedFile;
  bool _isVideo = false;
  bool _isRecording = false;
  Timer? _progressTimer;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<String> _getFilePath(String ext) async {
    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    return filePath;
  }

  void _onTap() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _capturedFile = image;
        _isVideo = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void _onLongPressStart() async {
    try {
      await _initializeControllerFuture;
      final path = await _getFilePath("mp4");
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _progress = 0;
      });

      _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          _progress += 0.02;
          if (_progress >= 1.0) {
            _onLongPressEnd();
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void _onLongPressEnd() async {
    if (!_isRecording) return;
    try {
      final video = await _controller.stopVideoRecording();
      _progressTimer?.cancel();
      setState(() {
        _capturedFile = video;
        _isRecording = false;
        _isVideo = true;
        _progress = 0;
      });
    } catch (e) {
      print(e);
    }
  }

  void _reset() {
    setState(() {
      _capturedFile = null;
      _isVideo = false;
      _progress = 0;
    });
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _onTap,
      onLongPressStart: (_) => _onLongPressStart(),
      onLongPressEnd: (_) => _onLongPressEnd(),
      child: _isRecording
          ? CircularPercentIndicator(
              radius: 36.0,
              lineWidth: 5.0,
              percent: _progress,
              progressColor: Colors.red,
              backgroundColor: Colors.white,
              center: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            )
          : Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
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
                    ? Center(
                        child: Icon(Icons.videocam,
                            color: Colors.white, size: 100))
                    : Image.file(File(_capturedFile!.path), fit: BoxFit.cover),
              ),
            Positioned(
              bottom: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, size: 40, color: Colors.white),
                    onPressed: _reset,
                  ),
                  SizedBox(width: 40),
                  IconButton(
                    icon:
                        Icon(Icons.check, size: 40, color: Colors.greenAccent),
                    onPressed: () {}, // Add confirm logic
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              child: _buildCaptureButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("Upload", style: TextStyle(color: Colors.white)),
          Text("Drafts", style: TextStyle(color: Colors.white)),
          Icon(Icons.circle, size: 20, color: Colors.white),
          Text("Camera",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text("Write", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          if (_capturedFile != null) _buildPreviewOverlay(),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
                child:
                    _capturedFile == null ? _buildCaptureButton() : SizedBox()),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNav()),
        ],
      ),
    );
  }
}