import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../widget/alert_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];
  List<VideoPlayerController?> _videoControllers = [];

  // Unified method to pick multiple images and videos
  Future<void> _pickMedia({required bool isVideo}) async {
    if (isVideo) {
      final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedVideo != null) {
        File videoFile = File(pickedVideo.path);
        setState(() {
          _mediaFiles.add(videoFile);
          _initializeVideoPlayer(videoFile);
        });
      }
    } else {
      final pickedImages = await _picker.pickMultiImage();
      if (pickedImages != null) {
        setState(() {
          _mediaFiles.addAll(pickedImages.map((file) => File(file.path)));
          _videoControllers.addAll(List.generate(
              pickedImages.length, (_) => null)); // Add placeholders for images
        });
      }
    }
  }

  Future<void> _initializeVideoPlayer(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    setState(() {
      _videoControllers.add(controller);
    });
  }

  Future<void> _captureMedia({required bool isVideo}) async {
    if (await _requestCameraPermission()) {
      final pickedFile = isVideo
          ? await _picker.pickVideo(source: ImageSource.camera)
          : await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        setState(() {
          _mediaFiles.add(file);
          if (isVideo) {
            _initializeVideoPlayer(file);
          } else {
            _videoControllers.add(null); // Placeholder for images
          }
        });
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    return status.isGranted;
  }

  void _removeMedia(int index) {
    setState(() {
      if (_isVideo(_mediaFiles[index])) {
        _videoControllers[index]?.dispose();
      }
      _mediaFiles.removeAt(index);
      _videoControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  bool _isVideo(File file) {
    return file.path.endsWith('.mp4') ? true : false;
  }

  Widget _buildVideoPlayer(VideoPlayerController? controller) {
    if (controller != null && controller.value.isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: VideoPlayer(controller),
          ),
          IconButton(
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
            onPressed: () {
              setState(() {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
              });
            },
          ),
        ],
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  // Function to show the popup for selecting image or video
  void _showMediaSelectionDialog() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Select Images'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickMedia(isVideo: false);
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Select Videos'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickMedia(isVideo: true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back),
          title: const Text("Create Post"),
          actions: [
            ElevatedButton(onPressed: (){
              print(Keyword);
              //  showHelpDialog(context);
            }, child: Text("Post"))
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      onChanged: (value) {
                        setState(() {
                          Keyword = extractHashtags(value);
                        });
                      },
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (_mediaFiles.isNotEmpty)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: _mediaFiles.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          _isVideo(_mediaFiles[index])
                              ? (index < _videoControllers.length &&
                                      _videoControllers[index] != null)
                                  ? _buildVideoPlayer(_videoControllers[index])
                                  : const Center(
                                      child: CircularProgressIndicator())
                              : Image.file(
                                  _mediaFiles[index],
                                  fit: BoxFit.cover,
                                  height: 150,
                                  width: 150,
                                ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeMedia(index),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 15, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_photo_alternate,
                              color: Colors.green),
                          onPressed: _showMediaSelectionDialog,
                        ),
                        Text("Photos/Videos",style: AppTextStyles.poppinsRegular().copyWith(fontSize: 10),)
                      ],
                    ),
                      Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.people, color: Colors.blue),
                          onPressed: () => _captureMedia(isVideo: true),
                        ),
                         Text("Tag People",style: AppTextStyles.poppinsRegular().copyWith(fontSize: 10),)
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.blue),
                          onPressed: () => _captureMedia(isVideo: false),
                        ),
                         Text("Camera",style: AppTextStyles.poppinsRegular().copyWith(fontSize: 10),)
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.videocam, color: Colors.red),
                          onPressed: () => _captureMedia(isVideo: true),
                        ),
                         Text("Video Camera",style: AppTextStyles.poppinsRegular().copyWith(fontSize: 10),)
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  List<String> extractHashtags(String text) {
  // Split the text by spaces and keep all words
  List<String> words = text.split(' ');

  // Extract hashtags from words and allow incomplete hashtags (the word being typed)
  List<String> hashtags =
      words.where((word) => word.startsWith('#')).toList
      ();

  return hashtags;
}
   List<String> Keyword = []; 
}
