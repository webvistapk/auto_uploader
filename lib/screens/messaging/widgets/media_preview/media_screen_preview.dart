import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

class MediaMessagingScreen extends StatefulWidget {
  final List<String> initialMediaList;

  MediaMessagingScreen({Key? key, required this.initialMediaList})
      : super(key: key);

  @override
  _MediaMessagingScreenState createState() => _MediaMessagingScreenState();
}

class _MediaMessagingScreenState extends State<MediaMessagingScreen> {
  late List<String> mediaList;
  final TextEditingController _messageController = TextEditingController();
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    mediaList = widget.initialMediaList;
  }

  // Opens gallery to pick a new image or video
  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
        source: ImageSource.gallery); // You can handle videos similarly.
    if (file != null) {
      setState(() {
        mediaList.add(file.path); // Add the selected file to the list
      });
    }
  }

  // Widget to display media (image or video)
  Widget _buildMediaWidget(String mediaUrl) {
    if (mediaUrl.endsWith('.mp4')) {
      _videoController = VideoPlayerController.network(mediaUrl)
        ..initialize().then((_) {
          setState(() {});
          _videoController.play();
        });
      return _videoController.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            )
          : Center(child: CircularProgressIndicator());
    } else {
      return Image.network(
        mediaUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Center(child: Icon(Icons.broken_image, size: 50)),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Handle options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Media Display Section
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.black12,
            child: mediaList.isNotEmpty
                ? _buildMediaWidget(mediaList[0])
                : Center(child: Text("No Media Available")),
          ),

          // Media List Section
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mediaList.length + 1, // Include the "add" container
              itemBuilder: (context, index) {
                if (index == mediaList.length) {
                  // "Add Media" container
                  return GestureDetector(
                    onTap: _pickMedia,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 80,
                      width: 80,
                      color: Colors.grey[300],
                      child: Icon(Icons.add, size: 40),
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
                      margin: const EdgeInsets.all(8.0),
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        image: mediaList[index].endsWith('.mp4')
                            ? null
                            : DecorationImage(
                                image: NetworkImage(mediaList[index]),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: mediaList[index].endsWith('.mp4')
                          ? Center(
                              child: Icon(Icons.videocam, color: Colors.white),
                            )
                          : null,
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
                  onPressed: () {
                    // Handle message send action
                    if (_messageController.text.isNotEmpty) {
                      print('Message Sent: ${_messageController.text}');
                      _messageController.clear();
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
