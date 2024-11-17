import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/screens/profile/imageFullScreen.dart';
import 'package:mobile/screens/profile/widgets/ReelPostGrid.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class PostWidget extends StatefulWidget {
  final String postId;
  final String username;
  final String location;
  final String date;
  final String caption;
  final List<String> mediaUrls;
  final String profileImageUrl;
  final bool isVideo;
  final String likes;
  final String comments;
  final String shares;
  final String saved;
  final VoidCallback refresh;
  final bool showFollowButton; // New parameter to show/hide follow button
  final bool isInteractive; // New parameter for tap-to-navigate
  const PostWidget({
    Key? key,
    required this.postId,
    required this.username,
    required this.location,
    required this.date,
    required this.caption,
    required this.mediaUrls,
    required this.profileImageUrl,
    required this.isVideo,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saved,
    required this.refresh,
    this.showFollowButton = false,
    this.isInteractive = false,
  }) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.profileImageUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
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
              ),
              /* if (widget.showFollowButton)
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Follow',
                    style: TextStyle(fontSize: 12),
                  ),
                ),*/
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: widget.isInteractive
                ? () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SinglePost(postId: widget.postId),
                        ));
                  }
                : () {
                    if (widget.isVideo) {
                      Navigator.push(
                        context,
                        CupertinoDialogRoute(
                          builder: (_) => FullscreenVideoPlayer(
                            videoUrl: "${widget.mediaUrls[0]}",
                          ),
                          context: context,
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => postFullScreen(
                                mediaUrls: widget.mediaUrls,
                                initialIndex: _currentImageIndex)),
                      );
                    }
                  },
            child: widget.isVideo
                ? _buildVideoPlayer(widget.mediaUrls.first)
                : Column(
                    children: [
                      _buildImageCarousel(widget.mediaUrls),
                      SizedBox(height: 8),
                      _buildImageIndicator(widget.mediaUrls.length),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildInteractionIcon(FontAwesomeIcons.share, widget.shares),
              SizedBox(width: 10),
              _buildInteractionIcon(CupertinoIcons.bookmark, widget.saved),
              SizedBox(width: 10),
              _buildInteractionIcon(Icons.favorite_border, widget.likes),
              SizedBox(width: 10),
              _buildInteractionIcon(
                  CupertinoIcons.chat_bubble_fill, widget.shares),
            ],
          ),
          const SizedBox(height: 8),
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
              const SizedBox(height: 8),
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

  Widget _buildInteractionIcon(IconData icon, String count) {
    return Column(
      children: [
        Icon(icon, size: 20),
        Text(count, style: TextStyle(fontSize: 9)),
      ],
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    print("VIDEO URL : ${videoUrl}");
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 400,
        child: VideoPlayerWidget(videoUrl: videoUrl),
      ),
    );
  }

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
        height: 350,
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

  Widget _buildImageIndicator(int itemCount) {
    return itemCount < 2
        ? Container()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentImageIndex == index ? Colors.black : Colors.grey,
                ),
              );
            }),
          );
  }
}

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
        // _controller.play();
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
        : Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.grey),
          );
  }
}
