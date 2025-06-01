import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:mobile/screens/post/view/camera/preview_screen.dart';
import 'package:path_provider/path_provider.dart';

class CustomCameraScreen extends StatefulWidget {
  @override
  _CustomCameraScreenState createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  late File _mediaFile;

  void _onFile(File file) {
    setState(() {
      _mediaFile = file;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewScreen(file: _mediaFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CameraCamera(
            onFile: _onFile,
            resolutionPreset: ResolutionPreset.ultraHigh,
            enableAudio: true,
          ),
        ],
      ),
    );
  }
}
