// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:photo_manager/photo_manager.dart';

// class WhatsAppMediaPicker extends StatefulWidget {
//   const WhatsAppMediaPicker({Key? key}) : super(key: key);

//   @override
//   State<WhatsAppMediaPicker> createState() => _WhatsAppMediaPickerState();
// }

// class _WhatsAppMediaPickerState extends State<WhatsAppMediaPicker> {
//   bool isFrontCamera = false;
//   List<AssetEntity> galleryItems = [];
//   int currentPage = 0;
//   int lastPage = -1;
//   bool isLoadingGallery = false;

//   Future<void> fetchGalleryItems() async {
//     if (isLoadingGallery || lastPage == currentPage) return;

//     setState(() {
//       isLoadingGallery = true;
//     });

//     final permission = await PhotoManager.requestPermissionExtend();
//     if (permission.isAuth) {
//       final albums = await PhotoManager.getAssetPathList(
//         type: RequestType.image,
//         onlyAll: true,
//       );
//       final items =
//           await albums[0].getAssetListPaged(page: currentPage, size: 20);

//       setState(() {
//         galleryItems.addAll(items);
//         lastPage = currentPage;
//         currentPage++;
//         isLoadingGallery = false;
//       });
//     } else {
//       PhotoManager.openSetting();
//     }
//   }

//   late CameraController _controller;
//   late List<CameraDescription> _cameras;
//   bool _isRecording = false;
//   String? _videoPath;
//   int _currentCameraIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   // Initialize the camera and check for permissions
//   Future<void> _initializeCamera() async {
//     final status = await Permission.camera.request();
//     if (status.isGranted) {
//       _cameras = await availableCameras();
//       _controller = CameraController(
//         _cameras[_currentCameraIndex],
//         ResolutionPreset.high,
//       );
//       await _controller.initialize();
//       setState(() {});
//     }
//   }

//   // Start or stop video recording
//   void _toggleRecording() async {
//     if (_isRecording) {
//       await _controller.stopVideoRecording();
//       setState(() {
//         _isRecording = false;
//       });
//     } else {
//       final tempDir = await getTemporaryDirectory();
//       final videoPath =
//           '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
//       await _controller.startVideoRecording();
//       setState(() {
//         _isRecording = true;
//         _videoPath = videoPath;
//       });
//     }
//   }

//   // Switch between front and back cameras
//   void _toggleCamera() {
//     _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
//     _controller = CameraController(
//       _cameras[_currentCameraIndex],
//       ResolutionPreset.high,
//     );
//     _initializeCamera();
//   }

//   // Handle media selection when tapped
//   void _selectImage(int index) {
//     // Handle image selection logic here
//     print('Selected image: ${galleryItems[index].title}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_controller.value.isInitialized) {
//       return Center(child: CircularProgressIndicator());
//     }
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Camera Preview
//             Expanded(
//               flex: 2,
//               child: Stack(
//                 children: [
//                   CameraPreview(_controller),
//                   Positioned(
//                     top: 16,
//                     left: 16,
//                     child: IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close, color: Colors.white),
//                     ),
//                   ),
//                   Positioned(
//                     top: 16,
//                     right: 16,
//                     child: IconButton(
//                       onPressed: () => _toggleCamera(),
//                       icon: const Icon(Icons.cameraswitch, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Photo/Video Toggle Options
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               decoration: const BoxDecoration(
//                 color: Colors.black,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _buildOption("All", isSelected: true),
//                 ],
//               ),
//             ),

//             // Gallery Section
//             Expanded(
//               flex: 1,
//               child: NotificationListener<ScrollNotification>(
//                 onNotification: (ScrollNotification scrollInfo) {
//                   if (scrollInfo.metrics.pixels ==
//                       scrollInfo.metrics.maxScrollExtent) {
//                     fetchGalleryItems();
//                   }
//                   return false;
//                 },
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 4,
//                     crossAxisSpacing: 4,
//                     mainAxisSpacing: 4,
//                   ),
//                   itemCount: galleryItems.length,
//                   itemBuilder: (context, index) {
//                     return FutureBuilder<Uint8List?>(
//                       // Load image thumbnails
//                       future: galleryItems[index].thumbnailData,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//                         if (snapshot.hasData) {
//                           return GestureDetector(
//                             onTap: () => _selectImage(index),
//                             child:
//                                 Image.memory(snapshot.data!, fit: BoxFit.cover),
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),

//             // Center Button for Image/Video Control
//             Positioned(
//               bottom: 20,
//               left: MediaQuery.of(context).size.width / 2 - 40,
//               child: GestureDetector(
//                 onTap: () {
//                   // Handle single tap to pick image
//                   print('Center button tapped for picking image');
//                 },
//                 onLongPress: () {
//                   // Start recording video when long pressed
//                   _toggleRecording();
//                 },
//                 onLongPressEnd: (_) {
//                   // Stop recording video when long press ends
//                   _toggleRecording();
//                 },
//                 child: CircleAvatar(
//                   radius: 40,
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     _isRecording ? Icons.stop : Icons.videocam,
//                     color: Colors.black,
//                     size: 36,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOption(String title, {bool isSelected = false}) {
//     return Text(
//       title,
//       style: TextStyle(
//         color: isSelected ? Colors.white : Colors.grey,
//         fontSize: 16,
//         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//       ),
//     );
//   }
// }

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class MediaScreen extends StatefulWidget {
  @override
  _MediaScreenState createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final ImagePicker _picker = ImagePicker();
  late List images = [];
  late List<Asset> videos = [];
  CameraController? _cameraController;
  late VideoPlayerController _videoPlayerController;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.high);

    await _cameraController?.initialize();
    setState(() {
      _isCameraReady = true;
    });
  }

  Future<void> _pickPhotos() async {
    try {
      final List<XFile>? result = await _picker.pickMultiImage();
      if (result != null && result.isNotEmpty) {
        setState(() {
          images = result;
        });
      }
    } catch (e) {
      print("Error picking photos: $e");
    }
  }

  List<String> videoPaths = [];

  // Function to pick multiple videos from the gallery
  Future<void> _pickVideos() async {
    try {
      // Pick multiple video files from the gallery
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true, // Allow multiple selections
      );

      if (result != null) {
        // Extract video paths and add them to the list
        setState(() {
          videoPaths = result.paths.cast<String>();
        });
      }
    } catch (e) {
      print("Error picking videos: $e");
    }
  }

  // Take a photo with the camera
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        print("Photo taken: ${image.path}");
      }
    } catch (e) {
      print("Error taking photo: $e");
    }
  }

  // Record a video with the camera
  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        print("Video recorded: ${video.path}");
      }
    } catch (e) {
      print("Error recording video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Media Picker")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 200,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('Gallery Photos'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickPhotos();
                                },
                              ),
                              ListTile(
                                title: Text('Gallery Video'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickVideos();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text("Attachment"),
                ),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 200,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('Photo'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _takePhoto();
                                },
                              ),
                              ListTile(
                                title: Text('Video'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _recordVideo();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text("Camera"),
                ),
              ],
            ),
            SizedBox(height: 20),
            images.isNotEmpty
                ? Wrap(
                    children: images
                        .map((image) => AssetThumb(
                              asset: image,
                              width: 100,
                              height: 100,
                            ))
                        .toList(),
                  )
                : SizedBox.shrink(),
            videos.isNotEmpty
                ? Wrap(
                    children: videos
                        .map((video) => Icon(Icons.video_library, size: 100))
                        .toList(),
                  )
                : SizedBox.shrink(),
            _isCameraReady
                ? CameraPreview(_cameraController!)
                : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MediaScreen(),
  ));
}
