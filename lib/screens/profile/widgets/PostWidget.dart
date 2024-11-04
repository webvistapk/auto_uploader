import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/screens/profile/imageFullScreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../../../common/app_colors.dart';
import '../../../common/app_size.dart';
import '../../widgets/full_screen_image.dart';

class PostWidget extends StatefulWidget {
  final bool isTrue;
  final String postId;
  final String username;
  final String location;
  final String date;
  final String caption;
  final List<String> mediaUrls; // List of media URLs (multiple images or video)
  final String profileImageUrl;
  final String isVideo; // To determine if the post contains a video
  final String likes;
  final String comments;
  final String shares;
  final String saved;
  final VoidCallback refresh;

  const PostWidget({
    Key? key,
    this.isTrue=true,
    required this.postId,
    required this.username,
    required this.location,
    required this.date,
    required this.caption,
    required this.mediaUrls, // Updated to accept a list of URLs
    required this.profileImageUrl,
    required this.isVideo,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saved,
    required this.refresh,
  }) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int _currentImageIndex = 0; // Track the current image index in the slider

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
                    setState(() {
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

          // Post Media (Image Carousel or Video)
          InkWell(
            onTap:widget.isTrue?() {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SinglePost(postId: widget.postId)));
            }:(){
              // Navigate to a new fullscreen image screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => postFullScreen(
                      mediaUrls: widget.mediaUrls,
                      initialIndex: _currentImageIndex
                  )
                ),
              );
            },
            child: widget.isVideo == 'video'
                ? _buildVideoPlayer(widget.mediaUrls.first) // If it's a video, show video player
                : Column(
              children: [
                _buildImageCarousel(widget.mediaUrls), // Handle multiple images with a carousel
                SizedBox(height: 8),
                _buildImageIndicator(widget.mediaUrls.length), // Dots indicator below the carousel
              ],
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

          // Caption and Comments
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
        child: VideoPlayerWidget(videoUrl: videoUrl),
      ),
    );
  }

  // Method to build an image carousel for multiple images
  Widget _buildImageCarousel(List<String> imageUrls) {
    return CarouselSlider.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index, realIndex) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      },
      options: CarouselOptions(
        height: 200,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
        autoPlay: false,
        onPageChanged: (index, reason) {
          setState(() {
            _currentImageIndex = index;
          });
        },
      ),
    );
  }

  // Dots indicator widget
  Widget _buildImageIndicator(int itemCount) {
    return itemCount<2?Container():Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentImageIndex == index ? Colors.black : Colors.grey,
          ),
        );
      }),
    );
  }
}


// Widget for Video Player
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;


  VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isBuffering = true;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
        setState(() {
          // Check if the video is buffering
          _isBuffering = _controller.value.isBuffering;
        });
      })
      ..initialize().then((_) {
        setState(() {
          _isBuffering = false; // Video initialized, stop buffering
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.isInitialized
              ? _controller.value.aspectRatio
              : 16 / 9,
          child: VideoPlayer(_controller),
        ),
        if (!_controller.value.isInitialized || _isBuffering )
          Center(
            child: Container(
              width: 60, // Adjust the size for YouTube-like spinner
              height: 60,
              child: const CircularProgressIndicator(
                strokeWidth: 4.0,
                color: AppColors.blue, // White spinner for YouTube-like effect
              ),
            ),
          ),
      ],
    );
  }
}
