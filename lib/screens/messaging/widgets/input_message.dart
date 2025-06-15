import 'dart:developer';
import 'dart:io'; // For File class
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/controller/function/AudioController.dart';
import 'package:mobile/screens/messaging/model/chat_model.dart';
import 'package:mobile/screens/messaging/widgets/media_preview/media_screen_preview.dart';
import 'package:mobile/screens/post/create_post_screen.dart';
import 'package:mobile/screens/post/view/add_post_camera.dart';
import 'package:mobile/screens/profile/widgets/AudioRecordingWidget.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController messageController;
  final onPressedSend;
  final voicePressed;
  final onCameraChat;
  final ChatModel chatModel;
  ChatInputField(
      {super.key,
      required this.messageController,
      this.onPressedSend,
      this.onCameraChat,
      required this.chatModel,
      this.voicePressed});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  @override
  void initState() {
    super.initState();

    _audioController.init();
    widget.messageController.addListener(() {
      setState(() {}); // Rebuild the widget when text changes
    });
  }

  final AudioController _audioController = AudioController();
  final List<File> _selectedFiles = [];

  @override
  void dispose() {
    widget.messageController.dispose();

    _audioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _selectedFiles.isNotEmpty &&
              _selectedFiles.any((f) => f.path.endsWith('.m4a'))
          ? AudioWidget(
              controller: _audioController,
              audioFile:
                  _selectedFiles.firstWhere((f) => f.path.endsWith('.m4a')),
              onDelete: _deleteRecording,
              showRecordingUI: _audioController.isRecording,
            )
          : Row(
              children: [
                // Emoji Button
                if (!_audioController.isRecording) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      // Handle emoji selection (Use a package like emoji_picker_flutter)
                      showEmojiPicker(context);
                    },
                  ),

                  // TextField
                  Expanded(
                    child: TextField(
                      controller: widget.messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 5, // Allow multiline input
                    ),
                  ),

                  // Attachments Button
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: Colors.grey,
                    ),
                    onPressed: () async {
                      // _showOptionsBottomSheet(context, "attachment");
                      mediaPaths.clear();
                      final result = await showFullScreenAlert(
                          context,
                          CreatePostScreen(
                            isChatCamera: true,
                          ));
                      if (result != null && result.isNotEmpty) {
                        setState(() {
                          mediaPaths.addAll(result.toList());
                        });
                        _confirmAndNavigate();
                      }
                      // Handle attachment (file picker or gallery)
                    },
                  ),

                  // Camera Button
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.grey,
                    ),
                    onPressed: () async {
                      // _showOptionsBottomSheet(context, "camera");
                      mediaPaths.clear();

                      final image = await showFullScreenAlertBool(
                          context,
                          AddPostCameraScreen(
                            isChatCamera: true,
                            routeChatCamera: true,
                            chatModel: widget.chatModel,
                            token: '',
                          ));

                      if (image) {
                        widget.onCameraChat;
                      }
                      // Handle camera action (open camera or photo picker)
                    },
                  ),
                ] else
                  Expanded(
                    child: AudioWidget(
                      controller: _audioController,
                      audioFile: null,
                      onDelete: _deleteRecording,
                      showRecordingUI: _audioController.isRecording,
                    ),
                  ),

                // Send Button or Voice Button
                widget.messageController.text.isNotEmpty ||
                        _selectedFiles.isNotEmpty
                    ? buildSendButton(_selectedFiles.isEmpty
                        ? widget.onPressedSend
                        : widget.voicePressed)
                    : buildVoiceButton(),
              ],
            ),
    );
  }

  // Send Button
  Widget buildSendButton(onPressed) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: onPressed),
    );
  }

  // Voice Input Button
  Widget buildVoiceButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.keyboard_voice_sharp, color: Colors.white),
        onPressed: () {
          // Handle voice input (start recording)
        },
      ),
    );
  }

  // Emoji Picker (can be enhanced with a package)
  void showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 100, // A basic example, can be replaced with emojis
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Add the emoji to the text input field
                  widget.messageController.text += '😊'; // Example emoji
                  Navigator.pop(context);
                },
                child: Center(
                  child: Text(
                    '😊',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  final ImagePicker _picker = ImagePicker();
  List<File> mediaPaths = []; // Store File objects instead of String paths

  // Pick Photos
  Future<void> _pickPhotos() async {
    try {
      mediaPaths.clear();
      final result = await showFullScreenAlert(
          context,
          CreatePostScreen(
            isChatCamera: true,
          ));
      if (result != null && result.isNotEmpty) {
        setState(() {
          mediaPaths.addAll(result.toList());
        });
        _confirmAndNavigate();
      }
    } catch (e) {
      print("Error picking photos: $e");
    }
  }

  // Pick Videos
  Future<void> _pickVideos() async {
    try {
      mediaPaths.clear();
      final result = await showFullScreenAlert(
          context,
          CreatePostScreen(
            isChatCamera: true,
          ));
      if (result != null) {
        setState(() {
          mediaPaths.addAll(result.toList());
        });
        _confirmAndNavigate();
      }
    } catch (e) {
      print("Error picking videos: $e");
    }
  }

  // Take Photo
  Future<void> _takePhoto() async {
    try {
      mediaPaths.clear();
      List<File>? image = await showFullScreenAlert(
          context,
          AddPostCameraScreen(
            isChatCamera: true,
            token: '',
          ));

      if (image != null) {
        setState(() {
          mediaPaths.addAll(image);
        });
        _confirmAndNavigate();
      }
    } catch (e) {
      print("Error taking photo: $e");
    }
  }

  // Record Video
  Future<void> _recordVideo() async {
    try {
      mediaPaths.clear();
      final video = await showFullScreenAlert(
          context,
          AddPostCameraScreen(
            isChatCamera: true,
            token: '',
          ));
      if (video != null) {
        setState(() {
          mediaPaths.addAll(video);
        });
        _confirmAndNavigate();
      }
    } catch (e) {
      print("Error recording video: $e");
    }
  }

  // In your _MessageWidgetState:
  Future<void> _startRecording() async {
    try {
      setState(() {
        _selectedFiles.removeWhere((f) => f.path.endsWith('.m4a'));
      });
      await _audioController.startRecording();
      setState(() {});
    } catch (e) {
      print('Recording error: $e');
      setState(() {});
    }
  }

  Future<void> _stopRecording() async {
    try {
      final audioFile = await _audioController.stopRecording();
      if (audioFile != null) {
        setState(() {
          _selectedFiles.add(audioFile);
        });
      }
    } catch (e) {
      print('Stop recording error: $e');
    }
    setState(() {});
  }

  Future<void> _deleteRecording() async {
    if (_audioController.isPlaying) {
      await _audioController.audioPlayer.stop();
    }
    setState(() {
      _selectedFiles.removeWhere((f) => f.path.endsWith('.m4a'));
    });
  }

  // Show Confirmation Dialog and Navigate
  void _confirmAndNavigate() {
    if (mediaPaths.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Selection'),
            content:
                const Text('Do you want to proceed with the selected media?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  log('Files list: $mediaPaths');
                  // debugger();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MediaMessagingScreen(
                        initialMediaList: mediaPaths,
                        chatModel: widget.chatModel,
                      ),
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<List<File>?> showFullScreenAlert(
      BuildContext context, Widget contentScreen) {
    return showDialog<List<File>>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: SizedBox.expand(
            child: Material(
              color: Colors.white,
              child: contentScreen,
            ),
          ),
        );
      },
    );
  }

  Future<bool> showFullScreenAlertBool(
      BuildContext context, Widget contentScreen) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: SizedBox.expand(
            child: Material(
              color: Colors.white,
              child: contentScreen,
            ),
          ),
        );
      },
    ).then((value) => value ?? false); // ensures a boolean is always returned
  }

  void _showOptionsBottomSheet(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type == "attachment") ...[
                ListTile(
                  leading: const Icon(Icons.photo_album, color: Colors.blue),
                  title: const Text('Gallery Photos'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhotos();
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.video_library, color: Colors.orange),
                  title: const Text('Gallery Videos'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideos();
                  },
                ),
              ],
              if (type == "camera") ...[
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam, color: Colors.red),
                  title: const Text('Record Video'),
                  onTap: () {
                    Navigator.pop(context);
                    _recordVideo();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
