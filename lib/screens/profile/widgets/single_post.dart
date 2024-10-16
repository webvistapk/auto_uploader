import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostWidget extends StatelessWidget {
  final String username;
  final String location;
  final String date;
  final String caption;
  final String mediaUrl; // Either image or video
  final String profileImageUrl;
  final String isVideo; // To determine if the post is a video
  final String likes;
  final String comments;
  final String shares;
  final String saved;

  const PostWidget({
    Key? key,
    required this.username,
    required this.location,
    required this.date,
    required this.caption,
    required this.mediaUrl,
    required this.profileImageUrl,
    required this.isVideo,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    location,
                    style: TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.more_horiz),
            ],
          ),
          SizedBox(height: 10),

          // Post Media (either Image or Video)
          isVideo=='video'
              ? _buildVideoPlayer(mediaUrl) // If it's a video, show video player
              : ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              mediaUrl, // Post Image
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),

          // Date and Interaction icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: TextStyle(color: Colors.black54, fontSize: 9),
                  ),
                  Text(
                    date,
                    style: TextStyle(color: Colors.black54, fontSize: 9),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Icon(Icons.bookmark_border, size: 20),
                      Text(saved, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Icon(Icons.favorite_border, size: 20),
                      Text(likes, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Icon(Icons.comment, size: 20),
                      Text(comments, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Icon(Icons.share, size: 20),
                      Text(shares, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),

          // Caption
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 11),
                  children: [
                    TextSpan(
                      text: '$username ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: caption),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'View all $comments comments',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to build video player for video posts
  Widget _buildVideoPlayer(String videoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
          height: 400,
          child: VideoPlayerWidget(videoUrl: videoUrl)),
    );
  }
}

// Widget for Video Player
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Auto-play the video
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Center(child: CircularProgressIndicator());
  }
}
