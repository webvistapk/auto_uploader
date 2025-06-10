import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/function/commentBottomSheet.dart';
import 'package:mobile/controller/function/postfunctions.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/SinglePostModel.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/screens/authantication/Access%20Info/accessinfo.dart';
import 'package:mobile/screens/post/pool/poll_bottom_sheet.dart';
import 'package:mobile/screens/profile/widgets/comment_Widget.dart';
import 'package:mobile/screens/profile/widgets/emojiBottomSheet.dart';
import 'package:mobile/screens/profile/widgets/messageBottomSheet.dart';
import 'package:mobile/screens/profile/widgets/pinCommentBottomSheet.dart';
import 'package:mobile/screens/profile/widgets/pinImage.dart';
import 'package:mobile/screens/profile/widgets/pinPost.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final List<String>? privacy;
  final String? userID;

  const PostWidget(
      {super.key,
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
      this.privacy,
      required this.userID});

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
    bool isIconBold = false;
    //debugger();
    return Builder(builder: (context) {
      var pro = context.watch<PostProvider>();
      return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.isSinglePost)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 13.92.sp),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(14)),
                          child: Image.network(
                            widget.profileImageUrl == null
                                ? AppUtils.userImage
                                : widget.profileImageUrl,
                            width: 45.42.sp,
                            height: 45.42.sp,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        if (widget.postModel.isReposted == false &&
                            widget.postModel.repostedBy != null)
                          Text(
                            "${widget.postModel.repostedBy!.username} Reposted this Photo",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.black,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),

            Padding(
              padding: EdgeInsets.only(left: 13.92.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    child: SizedBox(
                      width: 73.96.sp,
                      height: 73.96.sp,
                      child: Image.network(
                        widget.profileImageUrl.isEmpty
                            ? AppUtils.userImage
                            : widget.profileImageUrl,
                        fit: BoxFit
                            .cover, // Ensures the image covers the container without distortion
                      ),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Text(
                                    widget.username,
                                    style: TextStyle(
                                        fontSize: 24.sp,
                                        color: AppColors.black,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: 'fontBold'),
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    "@" + widget.username.removeAllWhitespace,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      color: AppColors.lightGrey,
                                    ),
                                  ),
                                  if (widget.postModel.repostedBy != null)
                                    Text(
                                      date!,
                                      style: TextStyle(
                                        fontSize: 7,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              widget.postModel.location ?? " New York, NY",
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            if (widget.postModel.repostedBy != null)
                              Row(
                                children: [
                                  Text(
                                    "Senior Journalist at Fox News",
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                  if (widget.postModel.isReposted!) ...[
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 8),
                                      decoration: BoxDecoration(
                                          color: AppColors.iconredColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3))),
                                      child: Text(
                                        "Chess with the best",
                                        style: TextStyle(
                                          fontSize: 5,
                                          color: AppColors.white,
                                        ),
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
                            //if (widget.isUserPost)
                            GestureDetector(
                              onTap: () {
                                _showOptionsMenu(
                                  context,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 40, left: 20, right: 10, bottom: 15),
                                child: Image.asset(
                                  AppIcons.three_dot,
                                  width: 36.sp,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                if (widget.postModel.repostedBy != null) ...[
                                  Image.asset(AppIcons.eyes),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.privacy?.first ?? '',
                                    style: TextStyle(
                                        fontSize: 7,
                                        color: AppColors.lightGrey),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // if (widget.isUserPost == true)
                  //   GestureDetector(
                  //     key: iconKey, // Unique key for dynamic positioning
                  //     onTap: () {
                  //       _showOptionsMenu(
                  //         context,
                  //         iconKey,
                  //       );
                  //     },
                  //     child: const Icon(Icons.more_vert, size: 20),
                  //   ),
                ],
              ),
            ),

            //const SizedBox(height: 10),
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
            SizedBox(height: 26.55.sp),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //if(false)

                      Row(
                        children: [
                          if (!widget.isUserPost &&
                              widget.postModel.showDm == true) ...[
                            GestureDetector(
                                onTap: () {
                                  CreateChat(widget.userID.toString(),
                                      widget.postId, context,
                                      isEmoji: true);
                                },
                                child:
                                    _buildInteractionIcon(AppIcons.emoji, '')),
                            const SizedBox(width: 10),
                            GestureDetector(
                                onTap: () {
                                  CreateChat(widget.userID.toString(),
                                      widget.postId, context);
                                },
                                child: _buildInteractionIcon(
                                    AppIcons.forward, '')),
                          ],
                          const SizedBox(width: 5),
                          GestureDetector(
                              onTap: widget
                                  .onPressLiked, // Call _likePost when the like icon is clicked
                              child: Row(
                                children: [
                                  Image.asset(
                                    widget.isLiked
                                        ? AppIcons.heart_filled
                                        : AppIcons.heart,
                                    width: 47.sp,
                                  ),
                                  // ImageIcon(
                                  //   AssetImage(widget.isLiked
                                  //       ? AppIcons.heart_filled
                                  //       : AppIcons.heart),
                                  //   size: 47.sp,
                                  //   color:
                                  //       widget.isLiked ? Colors.red : AppColors.white,

                                  // ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text("", style: TextStyle(fontSize: 24.sp)),
                                ],
                              )),
                        ],
                      ),
                      // Text("test"+
                      //   widget.location,
                      //   style: TextStyle(
                      //     fontSize: 7,
                      //     color: AppColors.darkGrey,
                      //   ),
                      // ),
                      SizedBox(height: 23.55.sp),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 10),
                          children: [
                            TextSpan(
                              text: '${widget.username}',
                              style: TextStyle(
                                  fontSize: 24.sp, fontFamily: 'fontBold'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 0,
                ),
                Center(child: _buildImageIndicator(widget.mediaUrls.length)),
                SizedBox(
                  width: 35,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.isSinglePost) const SizedBox(width: 10),
                    GestureDetector(
                        onTap: () {
                          showPinPostSheet(context);
                          //_showpimImage(context);

                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>AccessInfo()));
                        },
                        child: _buildInteractionIcon(AppIcons.pin, "")),
                    const SizedBox(width: 10),
                    pro.isReposted
                        ? const CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          )
                        : widget.postModel.isReposted == false
                            ? GestureDetector(
                                onTap: () async {
                                  log("Repost Data Fetching: ${widget.postModel.id}");
                                  await pro.createNewReposted(
                                      'post', widget.postModel.id);
                                  setState(() {
                                    isIconBold = true;
                                  });
                                },
                                child: _buildInteractionIcon(
                                    AppIcons.repost,
                                    widget.postModel.repostCount == null
                                        ? ""
                                        : "${widget.postModel.repostCount}",
                                    isBold: isIconBold))
                            : SizedBox(),
                    if (widget.postModel.showComment == true) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: widget.postModel.showComment == false
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
                        child: _buildInteractionIcon(
                            AppIcons.comment,
                            widget.comments == 0
                                ? ''
                                : widget.comments //show comments count
                            ),
                      ),
                    ],
                    if (widget.postModel.interactions!.contains('polls')) ...[
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                // debugger();
                                widget.postModel.polls!.any(
                                        (element) => element.isVoted == true)
                                    ? showPercentageResult(
                                        context,
                                        widget.postModel.polls!,
                                        false,
                                        widget.postModel.pollTitle ?? '',
                                        widget.postModel.pollDescription ?? '')
                                    : showPollModal(
                                        context,
                                        widget.postModel.polls ?? [],
                                        widget.postModel.pollTitle ?? '',
                                        widget.postModel.pollDescription ?? '');
                              },
                              child: const Icon(
                                Icons.poll_outlined,
                                size: 24,
                                color: Colors.black,
                              )),
                          Text('', style: TextStyle(fontSize: 24.sp))
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.caption}",
                    style: TextStyle(
                        fontSize: 24.sp,
                        color: AppColors.darkGrey,
                        fontFamily: 'Greycliff CF'),
                  ),
                  const SizedBox(height: 8),
                  widget.isSinglePost
                      ? !widget.postModel.interactions!.contains('comments')
                          ? CommentWidget(
                              postId: widget.postId,
                              isReelScreen: false,
                              commentIdToHighlight:
                                  widget.scrollCommentId.toString(),
                              replyIdToHighlight:
                                  widget.scrollCommentId.toString(),
                              scrollOffset: widget.scrollOffset,
                              isSinglePost: widget.isSinglePost,
                            )
                          : Text(
                              'Comments are disabled for this post',
                              style: TextStyle(
                                  color: AppColors.black, fontSize: 25.sp),
                            )
                      : !widget.postModel.interactions!.contains('comments')
                          ? InkWell(
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
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 8),
                              ),
                            )
                          : Container(),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      );
    });
  }

  Widget _buildInteractionIcon(
    String icon,
    String count, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          children: [
            if (isBold)
              Positioned(
                top: 1,
                left: 1,
                child: Image.asset(
                  icon,
                  height: 47.sp,
                  color:
                      Colors.black.withOpacity(0.3), // Shadow effect for bold
                ),
              ),
            Image.asset(
              icon,
              height: 47.sp,
            ),
          ],
        ),
        SizedBox(width: 3),
        Text(
          count,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight:
                isBold ? FontWeight.bold : FontWeight.normal, // Bold text
          ),
        ),
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
            if (widget.postTitle != null)
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
                          style: TextStyle(
                            color: AppColors.black,
                            fontFamily: 'fontBold',
                            fontSize: 36.sp,
                          )),
                      Text(
                        widget.postDescription ?? '',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 25.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!widget.isSinglePost) ...[
              Positioned(
                bottom: widget.postTitle == null ? 5 : 85,
                left: 5,
                //right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScreenIconBuild(AppIcons.event_link, "Event Link   "),
                    SizedBox(
                      height: 2,
                    ),
                    ScreenIconBuild(AppIcons.service_link, "Service Link"),
                    SizedBox(
                      height: 2,
                    ),
                    ScreenIconBuild(AppIcons.group_name, "Group Name",
                        padRight: 17),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
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

  Widget ScreenIconBuild(String image, labelText, {double padRight = 20}) {
    return Container(
        padding: EdgeInsets.only(left: 2, right: padRight, top: 2, bottom: 2),
        decoration: BoxDecoration(color: Color.fromARGB(83, 0, 0, 0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(image, height: 14),
            SizedBox(
              width: 4,
            ),
            Text(
              labelText,
              style: TextStyle(fontSize: 8, color: AppColors.white),
            )
          ],
        ));
  }

  Widget _buildImageIndicator(int itemCount) {
    return itemCount < 2
        ? Container()
        : Row(
            //  Text(
            //     '${_currentImageIndex + 1} of $itemCount', // Display "1 of 4" format
            //     style: TextStyle(
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

  void _showpimImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.78,
        child: PinImage(),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 162.sp, horizontal: 20),
            child: Column(
              children: [
                _buildBottomSheetItem(
                    AppIcons.person, "Account Information", 42.87, () {}),
                SizedBox(
                  height: 40.99.sp,
                ),
                _buildBottomSheetItem(AppIcons.bookmark, "Save", 26.48, () {}),
                SizedBox(
                  height: 100.sp,
                ),
                _buildBottomSheetItem(AppIcons.share, "Share", 41.34, () {}),
                SizedBox(
                  height: 64.sp,
                ),
                _buildBottomSheetItem(AppIcons.unfollow, "Unfollow", 38, () {}),
                SizedBox(
                  height: 39.16.sp,
                ),
                _buildBottomSheetItem(
                    AppIcons.bell, "Notifications", 42.83, () {}),
                SizedBox(
                  height: 28.89.sp,
                ),
                _buildBottomSheetItem(AppIcons.report, "Report", 38.45, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PinImage()));
                }),
                SizedBox(
                  height: 20,
                ),
                if (widget.isUserPost)
                  _buildBottomSheetItem(AppIcons.delete, "Delete", 47, () {
                    Provider.of<PostProvider>(context, listen: false)
                        .deletePost(widget.postId, context, false);
                  }),
              ],
            ),
          );
        });
  }

  Widget _buildBottomSheetItem(
      String icon, String text, double imageSize, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: double.infinity,
        child: Row(
          children: [
            Image.asset(
              icon,
              width: imageSize.sp,
            ),
            SizedBox(
              width: 10,
            ),
            Text(text, style: TextStyle(fontSize: 24.sp)),
          ],
        ),
      ),
    );
  }
}

// void CreateChat(String PostUserID,PostID, BuildContext context, {bool isEmoji=false}) async {
//   final response = await Provider.of<PostProvider>(context, listen: false)
//       .createChat(PostUserID, context);
//   if (response?.statusCode == 201) {
//     final responseData = jsonDecode(response!.body);

//     // Extract chat ID
//     final chatId = responseData['chat']['id'].toString();
//     if(isEmoji){
//        showEmojiBottomSheet(context,PostID, chatId);
//     }
//     else{
//     showMessageBottomSheet(context, chatId, PostID);
//     }
//   } else {
//     ToastNotifier.showErrorToast(context, "Unable to chat");
//   }
// }

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
