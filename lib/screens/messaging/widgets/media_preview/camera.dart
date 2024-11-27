import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<File?> _capturePhoto() async {
    final XFile file = await _cameraController.takePicture();
    return File(file.path);
  }

  Future<File?> _recordVideo() async {
    if (!isRecording) {
      await _cameraController.startVideoRecording();
      setState(() {
        isRecording = true;
      });
      return null;
    } else {
      final XFile file = await _cameraController.stopVideoRecording();
      setState(() {
        isRecording = false;
      });
      return File(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.switch_camera, color: Colors.white),
                  onPressed: () {
                    int nextCamera =
                        (cameras.indexOf(_cameraController.description) + 1) %
                            cameras.length;
                    _cameraController = CameraController(
                        cameras[nextCamera], ResolutionPreset.high);
                    _cameraController.initialize().then((_) {
                      setState(() {});
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.circle,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    final File? file = await _recordVideo();
                    if (file != null) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () async {
                    final File? file = await _capturePhoto();
                    if (file != null) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
