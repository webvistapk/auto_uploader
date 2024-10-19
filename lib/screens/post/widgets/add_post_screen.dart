import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/controller/providers/profile_provider.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/post/component/tag_users.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../widget/bottom_sheet_screen.dart';

class AddPostScreen extends StatefulWidget {
  final UserProfile userProfile;
  const AddPostScreen({super.key, required this.userProfile});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];
  List<VideoPlayerController?> _videoControllers = [];
  List<String> Keyword = [];

  get isFormFilled => false; // Initialize here

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
    return file.path.endsWith('.mp4');
  }

  Widget _buildVideoPlayer(VideoPlayerController? controller) {
    if (controller != null && controller.value.isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 0.95,
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
      },
    );
  }

  String? _selectedValue;
  final TextEditingController _keywordController = TextEditingController();
  List<String> hashtags = [];

  // Function to show the bottom sheet for posting
  void _showPostBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Confirmation Post",
                    style:
                        AppTextStyles.poppinsSemiBold().copyWith(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      size: 25,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Updated hashtag display
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: hashtags
                      .map((hashtag) => Text(
                            hashtag,
                            style: AppTextStyles.poppinsRegular(),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Choose who can see your post",
                style: AppTextStyles.poppinsSemiBold().copyWith(fontSize: 13),
              ),
              const SizedBox(height: 10),
              Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  hint: Text(
                    "Public",
                    style: AppTextStyles.poppinsRegular()
                        .copyWith(color: Colors.grey),
                  ),
                  value: _selectedValue,
                  underline: SizedBox(),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                  items: <String>['Public', 'Only Followers see', 'Only me']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedValue = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Add Keywords to Display",
                style: AppTextStyles.poppinsSemiBold().copyWith(fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _keywordController,
                cursorColor: Colors.black,
                maxLines: 4,
                onChanged: (text) {
                  setState(() {
                    hashtags = extractHashtags(text);
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintText: "#Keyword",
                  hintStyle: AppTextStyles.poppinsRegular()
                      .copyWith(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: isFormFilled
                    ? () {
                        // Handle confirmation action here
                      }
                    : null,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isFormFilled ? Colors.red : Colors.grey,
                  ),
                  child: Center(
                    child: Text(
                      "Confirm",
                      style: AppTextStyles.poppinsMedium()
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<PostProvider>();
  }

  @override
  Widget build(BuildContext context) {
    bool isFormFilled =
        _selectedValue != null && _keywordController.text.isNotEmpty;
    var size = MediaQuery.of(context).size;
    final pro = context.read<PostProvider>();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back),
          title: const Text("Create Post"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  showHelpBottomSheet(
                    context,
                    _textController.text.trim(),
                    [1],
                    Keyword,
                    "",
                    _mediaFiles,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  foregroundColor: Colors.white, // Text color
                  shadowColor: Colors.blueAccent, // Shadow color
                  elevation: 10, // Elevation for shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ).copyWith(
                  // Interactive states (hover, pressed, focused)
                  elevation: MaterialStateProperty.resolveWith<double?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return 15; // Elevation when pressed
                      }
                      return 10; // Default elevation
                    },
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.blue[700]; // Darker color when pressed
                      } else if (states.contains(MaterialState.hovered)) {
                        return Colors
                            .blue[600]; // Slightly darker color when hovered
                      }
                      return Colors.blue; // Default color
                    },
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(),
                  // horizontal: 24.0, vertical: 12.0
                  child: Text(
                    "Post",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        // Text input field for the post content
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextField(
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
                                  hintStyle: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Display media files
                              if (_mediaFiles.isNotEmpty) _buildMediaGrid(size),

                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.add_photo_alternate, color: Colors.green),
                onPressed: _showMediaSelectionDialog,
              ),
              Text("Photos/Videos", style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.people, color: Colors.blue),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const SearchableDialog();
                    },
                  );
                  // Handle tagging people functionality
                },
              ),
              Text("Tag People", style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.blue),
                onPressed: () {
                  _captureMedia(isVideo: false); // Open camera for photos
                },
              ),
              Text("Camera", style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.videocam, color: Colors.red),
                onPressed: () {
                  _captureMedia(isVideo: true); // Open camera for videos
                },
              ),
              Text("Video Camera", style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // Widget to build the grid of selected media files
  Widget _buildMediaGrid(Size size) {
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // Disable scrolling of GridView
      itemCount: _mediaFiles.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            _isVideo(_mediaFiles[index])
                ? (_videoControllers.length > index &&
                        _videoControllers[index] != null)
                    ? _buildVideoPlayer(_videoControllers[index])
                    : const Center(child: CircularProgressIndicator())
                : Image.file(
                    _mediaFiles[index],
                    fit: BoxFit.cover,
                    height: size.height * 0.40, // Adjust height as needed
                    width: double.infinity,
                  ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _removeMedia(index),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Function to show the Bottom Sheet
  void showHelpBottomSheet(
    BuildContext context,
    String postTitle,
    List<int> peopleTags,
    List<String> keywordsList,
    String privacyPost,
    List<File> mediaFiles,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allowing full height
      builder: (BuildContext context) {
        Keyword = extractHashtags(postTitle);
        final pro = context.read<PostProvider>();
        return BottomSheetScreen(
            userProfile: widget.userProfile,
            pro: pro,
            postTitle: postTitle,
            peopleTags: peopleTags,
            keywordsList: keywordsList,
            privacyPost: privacyPost,
            mediaFiles: mediaFiles);
      },
    );
  }

  List<String> extractHashtags(String text) {
    // Split the text by spaces and keep all words
    List<String> words = text.split(' ');

    // Extract hashtags from words and allow incomplete hashtags (the word being typed)
    List<String> hashtags =
        words.where((word) => word.startsWith('#')).toList();

    return hashtags;
  }
}
