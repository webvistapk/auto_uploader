import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/screens/messaging/widgets/media_preview/media_screen_preview.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController messageController;
  final onPressedSend;
  ChatInputField(
      {super.key, required this.messageController, this.onPressedSend});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(() {
      setState(() {}); // Rebuild the widget when text changes
    });
  }

  @override
  void dispose() {
    widget.messageController.dispose();
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
      child: Row(
        children: [
          // Emoji Button
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
            onPressed: () {
              _showPopupMenu(context, "attachment");
              // Handle attachment (file picker or gallery)
            },
          ),

          // Camera Button
          IconButton(
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.grey,
            ),
            onPressed: () {
              _showPopupMenu(context, "camera");
              // Handle camera action (open camera or photo picker)
            },
          ),

          // Send Button or Voice Button
          widget.messageController.text.isNotEmpty
              ? buildSendButton(widget.onPressedSend)
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
  List<String> mediaPaths = []; // Store paths of selected media

  // Pick Photos
  Future<void> _pickPhotos() async {
    try {
      final List<XFile>? result = await _picker.pickMultiImage();
      if (result != null && result.isNotEmpty) {
        setState(() {
          mediaPaths.addAll(result.map((file) => file.path).toList());
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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          mediaPaths.addAll(result.paths.cast<String>());
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
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          mediaPaths.add(image.path);
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
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        setState(() {
          mediaPaths.add(video.path);
        });
        _confirmAndNavigate();
      }
    } catch (e) {
      print("Error recording video: $e");
    }
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MediaMessagingScreen(initialMediaList: mediaPaths),
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

  // Method to show the PopupMenu based on the type (attachment or camera)
  void _showPopupMenu(BuildContext context, String type) async {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    if (type == "attachment") {
      await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          100.0, // x position of the menu
          100.0, // y position of the menu
          100.0, // width of the menu
          100.0, // height of the menu
        ),
        items: [
          PopupMenuItem<String>(
            value: 'galleryPhotos',
            child: Text('Gallery Photos'),
          ),
          PopupMenuItem<String>(
            value: 'galleryVideos',
            child: Text('Gallery Videos'),
          ),
        ],
        elevation: 8.0,
      ).then((value) {
        if (value == 'galleryPhotos') {
          _pickPhotos();
        } else if (value == 'galleryVideos') {
          _pickVideos();
        }
      });
    } else if (type == "camera") {
      await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          100.0, // x position of the menu
          100.0, // y position of the menu
          100.0, // width of the menu
          100.0, // height of the menu
        ),
        items: [
          PopupMenuItem<String>(
            value: 'photo',
            child: Text('Take Photo'),
          ),
          PopupMenuItem<String>(
            value: 'video',
            child: Text('Record Video'),
          ),
        ],
        elevation: 8.0,
      ).then((value) {
        if (value == 'photo') {
          _takePhoto();
        } else if (value == 'video') {
          _recordVideo();
        }
      });
    }
  }
}
