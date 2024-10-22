import 'package:flutter/material.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PostWidget extends StatefulWidget {
  final String postId;
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
  final VoidCallback refresh;

  const PostWidget(
      {Key? key,
      required this.postId,
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
      required this.refresh})
      : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
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
                backgroundImage: NetworkImage(widget.profileImageUrl),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.location,
                    style: TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                ],
              ),
              Spacer(),
              // More options icon with dropdown menu
              PopupMenuButton<int>(
                icon: Icon(Icons.more_horiz),
                onSelected: (value) {
                  if (value == 1) {
                    // Handle edit action
                    print('Edit Post');
                  } else if (value == 2) {
                    // Handle delete action
                    setState(() {
                      //Provider.of<PostProvider>(context,listen: false).deletePost(widget.postId,context);
                      widget.refresh();
                    });
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('Edit'),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),

          // Post Media (either Image or Video)
          widget.isVideo == 'video'
              ? _buildVideoPlayer(
                  widget.mediaUrl) // If it's a video, show video player
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.mediaUrl, // Display the media URL
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        // Image has fully loaded
                        return child;
                      } else {
                        // Image is still loading, show CircularProgressIndicator
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image),
                  )
                  /*  Image.network(
              widget.mediaUrl, // Post Image
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),*/
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
                    widget.location,
                    style: TextStyle(color: Colors.black54, fontSize: 9),
                  ),
                  Text(
                    widget.date,
                    style: TextStyle(color: Colors.black54, fontSize: 9),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Icon(Icons.bookmark_border, size: 20),
                      Text(widget.saved, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Icon(Icons.favorite_border, size: 20),
                      Text(widget.likes, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Icon(Icons.comment, size: 20),
                      Text(widget.comments, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Icon(Icons.share, size: 20),
                      Text(widget.shares, style: TextStyle(fontSize: 9)),
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
                      text: '${widget.username} ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.caption),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'View all ${widget.comments} comments',
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
