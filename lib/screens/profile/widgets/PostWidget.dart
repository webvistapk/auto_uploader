import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/screens/profile/imageFullScreen.dart';
import 'package:mobile/screens/profile/widgets/ReelPostGrid.dart';
import 'package:mobile/screens/profile/widgets/comment_Widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../../../models/UserProfile/CommentModel.dart';
import '../../../models/UserProfile/commentBottomSheet.dart';

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
  final bool showCommentSection; // New parameter to show/hide follow button
  final bool isInteractive; // New parameter for tap-to-navigate
  final bool
      isUserPost; //this parameter is used to check that post is users or followers
  const PostWidget(
      {Key? key,
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
      this.showCommentSection = false,
      this.isInteractive = false,
      required this.isUserPost})
      : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int _currentImageIndex = 0;
  bool isLiked = false;

  void _likePost() {
    setState(() {
      isLiked = !isLiked;
    });

    // Call the newLike method from PostProvider to update the like status on the server
    PostProvider().newLike(int.parse(widget.postId), context);
  }

  void showComments(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return widget.showCommentSection == false
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: CommentWidget(
                  isUsedSingle: true,
                  postId: postId,
                  isReelScreen: false,
                ))
            : CommentWidget(
                isUsedSingle: true,
                postId: postId,
                isReelScreen: false,
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Post ID is here ${widget.postId}");
    final GlobalKey iconKey = GlobalKey();
    if (widget.profileImageUrl
        .contains('http://147.79.117.253:8001http://147.79.117.253:8001')) {
      var image =
          'http://147.79.117.253:8001/media/profile/f5f2bace-a565-41a9-a03b-483311a86e0e8143963285425881007.jpg';
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.profileImageUrl.contains(
                          'http://147.79.117.253:8001http://147.79.117.253:8001')
                      ? NetworkImage(
                          'http://147.79.117.253:8001/media/profile/f5f2bace-a565-41a9-a03b-483311a86e0e8143963285425881007.jpg')
                      : NetworkImage(widget.profileImageUrl),
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
                if (widget.isUserPost == true)
                  GestureDetector(
                    key: iconKey, // Unique key for dynamic positioning
                    onTap: () {
                      _showOptionsMenu(
                        context,
                        iconKey,
                      );
                    },
                    child: Icon(Icons.more_vert, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
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
                  ? _buildVideoPlayer(widget.mediaUrls[0])
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
                GestureDetector(
                  onTap:
                      _likePost, // Call _likePost when the like icon is clicked
                  child: _buildInteractionIcon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    widget.likes,
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: widget.showCommentSection
                      ? null
                      : () => showComments(widget.postId),
                  child: _buildInteractionIcon(
                      CupertinoIcons.chat_bubble_fill, widget.shares),
                ),
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
                widget.showCommentSection
                    ? CommentWidget(
                        isUsedSingle: false,
                        postId: widget.postId,
                        isReelScreen: false,
                      )
                    : InkWell(
                        onTap: () {
                          showComments(widget.postId);
                        },
                        child: Text(
                          'View all ${widget.comments} comments',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      )
              ],
            ),
          ],
        ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 400,
            child: VideoPlayerWidget(videoUrl: videoUrl),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoDialogRoute(
                    builder: (_) => FullscreenVideoPlayer(
                      videoUrl: videoUrl,
                    ),
                    context: context,
                  ),
                );
              },
            ),
          ),
        ],
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

  void _showOptionsMenu(BuildContext context, GlobalKey key) {
    // Find the render box of the widget and calculate its position
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Define the position for the menu
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx, // Left
      offset.dy + size.height, // Top
      MediaQuery.of(context).size.width - offset.dx - size.width, // Right
      MediaQuery.of(context).size.height - offset.dy, // Bottom
    );

    // Show the options menu
    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'delete') {
        // Call the deletePost method and wait for its completion
        await Provider.of<PostProvider>(context, listen: false)
            .deletePost(widget.postId, context, false);

        // Trigger the refresh callback to update the UI
        widget.refresh();
      } else if (value == 'edit') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Edit functionality not implemented.")),
        );
      }
    });
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
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.videoUrl);
      await _controller.initialize();
      setState(() {
        _isError = false;
      });
    } catch (e) {
      debugPrint(widget.videoUrl);
      debugPrint("Video initialization error: $e");
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Center(
        child: Text("Failed to load video."),
      );
    }

    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoPlayer(_controller),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
