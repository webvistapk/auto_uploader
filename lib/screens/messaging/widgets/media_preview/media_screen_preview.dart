import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/screens/messaging/controller/chat_controller.dart';
import 'package:mobile/screens/messaging/model/chat_model.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class MediaMessagingScreen extends StatefulWidget {
  final List<File> initialMediaList;
  final ChatModel chatModel;

  MediaMessagingScreen(
      {Key? key, required this.initialMediaList, required this.chatModel})
      : super(key: key);

  @override
  _MediaMessagingScreenState createState() => _MediaMessagingScreenState();
}

class _MediaMessagingScreenState extends State<MediaMessagingScreen> {
  late List<File> mediaList;
  final TextEditingController _messageController = TextEditingController();
  VideoPlayerController? _videoController;
  FocusNode _textFieldFocusNode = FocusNode();
  bool isTextFieldFocused = false;

  @override
  void initState() {
    super.initState();
    mediaList = widget.initialMediaList;

    // Listen for focus changes on the text field
    _textFieldFocusNode.addListener(() {
      setState(() {
        isTextFieldFocused = _textFieldFocusNode.hasFocus;
      });
    });

    context.read<ChatController>();
  }

  // Opens gallery to pick multiple images or videos
  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();

    // Show the bottom sheet to select media type
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Pick Images'),
              onTap: () async {
                final List<XFile> images = await picker.pickMultiImage();
                if (images.isNotEmpty) {
                  setState(() {
                    mediaList.addAll(images.map((e) => File(e.path)));
                  });
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text('Pick Videos'),
              onTap: () async {
                final XFile? video =
                    await picker.pickVideo(source: ImageSource.gallery);
                if (video != null) {
                  setState(() {
                    mediaList.add(File(video.path));
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  bool isSending = false;

  // Widget to display media (image or video)
  Widget _buildMediaWidget(File mediaFile) {
    if (mediaFile.path.endsWith('.mp4')) {
      return VideoPlayerFile(videoFile: mediaFile);
    } else {
      return Image(
        image: FileImage(mediaFile),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return _buildShimmer(); // Show shimmer while loading
          }
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildShimmer(); // Show shimmer in case of error
        },
      );
    }
  }

  // Shimmer loading widget
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.grey,
      ),
    );
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    bool discard = await _showDiscardDialog(context);
    return discard;
  }

  // Show discard confirmation dialog
  Future<bool> _showDiscardDialog(BuildContext context) async {
    // Show the dialog and return the result of the user's choice (true or false)
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Discard Media?'),
          content: Text('Do you want to discard the selected files and exit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // User chose to discard
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User chose not to discard
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    // Return the value of the dialog (true if user selected "Yes", false otherwise)
    return discard!; // If dialog was closed without selection, return false
  }

  @override
  void dispose() {
    _messageController.dispose();
    _videoController?.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle the back button press
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          // leading: IconButton(
          //   icon: Icon(Icons.close, color: Colors.black),
          //   onPressed: _onWillPop,
          // ),
          centerTitle: true,
          title: Text("Media Preview's"),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {
                // Handle options menu
              },
            ),
          ],
        ),
        body: Builder(builder: (context) {
          var pro = context.watch<ChatController>();
          return Stack(
            children: [
              Column(
                children: [
                  // Media List Section
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 items per row
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1, // Square cards
                      ),
                      itemCount:
                          mediaList.length + 1, // Include the "add" container
                      itemBuilder: (context, index) {
                        if (index == mediaList.length) {
                          // "Add Media" container
                          return GestureDetector(
                            onTap: _pickMedia,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[300],
                              ),
                              child: Icon(Icons.add,
                                  size: 40, color: Colors.black),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // Set tapped media as the main display
                                mediaList.insert(0, mediaList.removeAt(index));
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black12,
                              ),
                              child: _buildMediaWidget(mediaList[index]),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // Message Input Section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Text Field
                        Expanded(
                          child: TextField(
                            focusNode: _textFieldFocusNode,
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Send Button
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: () async {
                            try {
                              await pro.sendMessage(
                                  _messageController.text.trim(),
                                  widget.chatModel.id,
                                  widget.initialMediaList);

                              if (mounted) {
                                setState(() {});
                              }
                              Navigator.pop(context, true);
                              // _scrollToBottom();
                            } catch (e) {
                              ToastNotifier.showErrorToast(
                                  context, e.toString());
                            }

                            _messageController.clear();
                            setState(() {});
                            // _scrollToBottom();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (pro.isSending)
                Positioned.fill(
                    child: Container(
                  color: Colors.white54,
                  child: Center(
                    child: _buildSprintLoader(),
                  ),
                ))
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSprintLoader() {
    return RotationTransition(
      turns: AlwaysStoppedAnimation(45 / 360), // Rotate continuously
      child: SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(
          strokeWidth: 6,
          valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue), // Color of the spinner
        ),
      ),
    );
  }
}

class VideoPlayerFile extends StatefulWidget {
  final File videoFile;

  VideoPlayerFile({Key? key, required this.videoFile}) : super(key: key);

  @override
  _VideoPlayerFileState createState() => _VideoPlayerFileState();
}

class _VideoPlayerFileState extends State<VideoPlayerFile> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Initialize the VideoPlayerController
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        // Ensure the video is initialized and set state to show the video
        setState(() {});
      });
  }

  // Toggle video playback
  void _togglePlayback() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? GestureDetector(
              onTap: _togglePlayback, // Toggle play/pause on tap
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video player widget
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  // Play button overlay when the video is paused
                  if (!_isPlaying)
                    Icon(
                      Icons.play_arrow,
                      size: 60,
                      color: Colors.white.withOpacity(0.8),
                    ),
                ],
              ),
            )
          : _buildShimmer(), // Show a loading indicator until the video is initialized
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.grey,
      ),
    );
  }
}
