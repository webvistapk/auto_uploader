import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/function/commentBottomSheet.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/SinglePostModel.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/post/pool/poll_bottom_sheet.dart';
import 'package:mobile/screens/profile/widgets/comment_Widget.dart';
import 'package:provider/provider.dart';
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
  final bool showCommentSection; // New parameter to show/hide follow button
  final bool isInteractive; // New parameter for tap-to-navigate
  final bool
      isUserPost; //this parameter is used to check that post is users or followers
  final onPressed;
  final onPressLiked;
  final bool isLiked;
  final String? scrollCommentId;
  final String? scrollReplyID;
  final int? scrollOffset;
  final PostModel postModel;
  final bool isSinglePost;
  final String? postTitle;
  final String? postDescription;
  final String? privacy;

  const PostWidget({
    super.key,
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
    required this.isUserPost,
    required this.onPressed,
    required this.onPressLiked,
    required this.isLiked,
    this.scrollCommentId,
    this.scrollReplyID,
    this.scrollOffset,
    required this.postModel,
    this.isSinglePost = false,
    this.postTitle,
    this.postDescription,
    this.privacy
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int _currentImageIndex = 0;

  String formatWithOrdinalSuffix(DateTime dateTime) {
    // Step 1: Format the date into "MMMM d yyyy"
    DateFormat formatter = DateFormat('MMM d yyyy');
    String formattedDate = formatter.format(dateTime);

    // Step 2: Add the ordinal suffix to the day
    int day = dateTime.day;
    String suffix;

    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else if (day % 10 == 1) {
      suffix = 'st';
    } else if (day % 10 == 2) {
      suffix = 'nd';
    } else if (day % 10 == 3) {
      suffix = 'rd';
    } else {
      suffix = 'th';
    }

    // Step 3: Replace the day with the day and suffix
    String dayWithSuffix = '$day$suffix';
    formattedDate = formattedDate.replaceFirst(RegExp(r'\d+'), dayWithSuffix);

    return formattedDate;
  }

  String? date;
  @override
  Widget build(BuildContext context) {
    final GlobalKey iconKey = GlobalKey();
    if (widget.profileImageUrl
        .contains('http://147.79.117.253:8001http://147.79.117.253:8001')) {
      var image =
          'http://147.79.117.253:8001/media/profile/f5f2bace-a565-41a9-a03b-483311a86e0e8143963285425881007.jpg';
    }
    date = formatWithOrdinalSuffix(DateTime.parse(widget.date));
  //debugger();
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.isSinglePost)
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Image.network(
                          widget.profileImageUrl == ''
                              ? AppUtils.userImage
                              : widget.profileImageUrl,
                          width: 28,
                          height: 28,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      if(false)
                      Text(
                        "${widget.username} Reposted this Photo",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.network(
                    widget.profileImageUrl == ''
                        ? AppUtils.userImage
                        : widget.profileImageUrl,
                    width: 35,
                    height: 35,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.username,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(
                                date!,
                                style: GoogleFonts.inter(
                                    fontSize: 7,
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if(false)
                              Text(
                                "Senior Journalist at Fox News",
                                style: GoogleFonts.inter(
                                    fontSize: 8,
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.normal),
                              ),
                              if (false) ...[
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  decoration: BoxDecoration(
                                      color: AppColors.iconredColor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3))),
                                  child: Text(
                                    "Chess with the best",
                                    style: GoogleFonts.inter(
                                        fontSize: 5,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!widget.isUserPost)
                            Image.asset(
                              AppIcons.three_dot,
                              width: 15,
                            ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Image.asset(AppIcons.eyes),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.privacy??'',
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                      fontSize: 7, color: AppColors.lightGrey),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: widget.onPressed,
              child: widget.isVideo
                  ? _buildVideoPlayer(widget.mediaUrls[0])
                  : Column(
                      children: [
                        _buildImageCarousel(widget.mediaUrls),
                        //const SizedBox(height: 8),
                      ],
                    ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(false)
                    Text(
                      widget.location,
                      style: GoogleFonts.inter(
                        fontSize: 7,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                            color: Colors.black, fontSize: 10),
                        children: [
                          TextSpan(
                            text: '${widget.username}',
                            style: GoogleFonts.publicSans(fontSize: 7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Center(child: _buildImageIndicator(widget.mediaUrls.length)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.isSinglePost)
                      _buildInteractionIcon(AppIcons.star, widget.shares),
                    const SizedBox(width: 10),
                    _buildInteractionIcon(AppIcons.repost, widget.shares),
                    const SizedBox(width: 10),
                    _buildInteractionIcon(AppIcons.share, widget.shares),
                    const SizedBox(width: 10),
                    _buildInteractionIcon(AppIcons.favorite, widget.saved),
                    const SizedBox(width: 10),
                    GestureDetector(
                        onTap: widget
                            .onPressLiked, // Call _likePost when the like icon is clicked
                        child: Column(
                          children: [
                            ImageIcon(
                              AssetImage(widget.isLiked
                                  ? AppIcons.heart_filled
                                  : AppIcons.heart),
                              size: 18,
                              color:
                                  widget.isLiked ? Colors.red : AppColors.black,
                            ),
                            // Icon(icon, size: 20),
                            Text(widget.likes,
                                style: GoogleFonts.inter(fontSize: 9)),
                          ],
                        )),
                    if (!widget.postModel.interactions!
                        .contains('comments')) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: widget.showCommentSection
                            ? null
                            : () => showComments(
                                  widget.postId,
                                  false,
                                  context,
                                  widget.scrollCommentId.toString(),
                                  scrollOffset: widget.scrollOffset,
                                  replyID: widget.scrollReplyID.toString(),
                                  commentCount: int.parse(widget.comments),
                                ),
                        child: _buildInteractionIcon(AppIcons.comment,
                            widget.comments //show comments count
                            ),
                      ),
                    ],
                    if (widget.postModel.interactions!.contains('polls')) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                          onTap: () {
                            widget.postModel.polls!
                                    .any((element) => element.isVoted == true)
                                ? showPercentageResult(
                                    context, widget.postModel.polls!)
                                : showPollModal(
                                    context,
                                    widget.postModel.polls ?? [],
                                    widget.postModel.pollTitle ?? '',
                                    widget.postModel.pollDescription ?? '');
                          },
                          child: const Icon(
                            Icons.poll_outlined,
                            size: 20,
                            color: Colors.black,
                          )),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "${widget.caption}",
              style: GoogleFonts.publicSans(
                fontSize: 10,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            widget.isSinglePost
                ? !widget.postModel.interactions!.contains('comments')
                    ? CommentWidget(
                        postId: widget.postId,
                        isReelScreen: false,
                        commentIdToHighlight: widget.scrollCommentId.toString(),
                        replyIdToHighlight: widget.scrollCommentId.toString(),
                        scrollOffset: widget.scrollOffset,
                        isSinglePost: widget.isSinglePost,
                      )
                    : Text(
                        'Comments are disabled for this post',
                        style: GoogleFonts.publicSans(
                            color: AppColors.black, fontSize: 11),
                      )
                : InkWell(
                    onTap: () {
                      showComments(widget.postId, false, context,
                          widget.scrollCommentId.toString(),
                          replyID: widget.scrollCommentId.toString(),
                          scrollOffset: widget.scrollOffset,
                          commentCount: int.parse(widget.comments),
                          isSinglePost: widget.isSinglePost);
                    },
                    child: Text(
                      'View all ${widget.comments} comments',
                      style: GoogleFonts.inter(color: Colors.grey, fontSize: 8),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionIcon(
    String icon,
    String count,
  ) {
    return Column(
      children: [
        ImageIcon(
          AssetImage(icon),
          size: 18,
        ),
        // Icon(icon, size: 20),
        Text(count, style: GoogleFonts.inter(fontSize: 9)),
      ],
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 400,
            child: VideoPlayerWidget(videoUrl: videoUrl),
          ),
          Positioned.fill(
            child: GestureDetector(onTap: widget.onPressed),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    return CarouselSlider.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index, realIndex) {
        return Stack(
          children: [
            // The image itself
            ClipRRect(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            // The caption container
            if (widget.postTitle!=null)
              Positioned(
                bottom: 5,
                left: 5,
                right: 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white.withOpacity(0.6),
                  ),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.postTitle ?? '',
                          style: GoogleFonts.inter(
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          )),
                      Text(
                        widget.postDescription ?? '',
                        style: GoogleFonts.inter(
                          color: AppColors.black,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!widget.isSinglePost) ...[
              Positioned(
                bottom: widget.postTitle==null?5:85,
                left: 5,
                //right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(AppIcons.event_link, height: 15),
                    SizedBox(
                      height: 2,
                    ),
                    Image.asset(AppIcons.service_link, height: 15),
                    SizedBox(
                      height: 2,
                    ),
                    Image.asset(
                      AppIcons.group_name,
                      height: 15,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                //right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(AppIcons.circle, height: 25),
                  ],
                ),
              )
            ]
          ],
        );
      },
      options: CarouselOptions(
        height: 450,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
        autoPlay: false,
        onPageChanged: (index, reason) {
          if (mounted) {
            setState(() {
              _currentImageIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildImageIndicator(int itemCount) {
    return itemCount < 2
        ? Container()
        : Row(
            //  Text(
            //     '${_currentImageIndex + 1} of $itemCount', // Display "1 of 4" format
            //     style: GoogleFonts.inter(
            //       fontSize: 10,
            //       color: AppColors.darkGrey, // Customize color as needed
            //     ),
            //   ),
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (index) {
              return Container(
                width: 5,
                height: 5,
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
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
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
        
         Provider.of<PostProvider>(context, listen: false)
            .deletePost(widget.postId, context, false);

        // Trigger the refresh callback to update the UI
        widget.refresh();
      } else if (value == 'edit') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Edit functionality not implemented.")),
        );
      }
    });
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeVideo();
    });
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.videoUrl);
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isError = false;
        });
      }
    } catch (e) {

      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
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
      return const Center(
        child: Text("Failed to load video."),
      );
    }

    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoPlayer(_controller),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
