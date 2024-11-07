import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';

class CreateStoryScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final String? token;
  const CreateStoryScreen({Key? key, required this.userProfile, this.token})
      : super(key: key);

  @override
  _CreateStoryScreenState createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  late CameraController _cameraController;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  XFile? selectedMedia;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  // Initialize the camera
  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras!.first, ResolutionPreset.high);
    await _cameraController.initialize();
    setState(() {
      isCameraInitialized = true;
    });
  }

  // Function to pick media from gallery
  Future<void> pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedMedia = pickedFile;
    });
  }

  // Function to capture a photo
  Future<void> capturePhoto() async {
    final XFile file = await _cameraController.takePicture();
    setState(() {
      selectedMedia = file;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview or selected media preview
          selectedMedia == null ? cameraPreviewWidget() : mediaPreviewWidget(),

          // Bottom controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon:
                      Icon(Icons.photo_library, color: Colors.white, size: 30),
                  onPressed: pickMedia,
                ),
                GestureDetector(
                  onTap: capturePhoto,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.camera_alt, color: Colors.black, size: 30),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.text_fields, color: Colors.white, size: 30),
                  onPressed: () {
                    // Implement text overlay feature here
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for camera preview
  Widget cameraPreviewWidget() {
    if (!isCameraInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_cameraController);
  }

  // Widget to preview selected media
  Widget mediaPreviewWidget() {
    return selectedMedia != null
        ? Image.file(
            File(selectedMedia!.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
        : Container();
  }
}
