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
