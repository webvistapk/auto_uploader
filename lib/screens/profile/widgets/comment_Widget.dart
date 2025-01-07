import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/post/comment_provider.dart';
import 'package:mobile/models/UserProfile/commentBottomSheet.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../controller/services/post/post_provider.dart';
import '../../../models/UserProfile/CommentModel.dart';

class CommentWidget extends StatefulWidget {
  final bool isReelScreen;
  final String postId;
  final String commentIdToHighlight;
  final String? replyIdToHighlight;
  final int? scrollOffset;
  bool isSinglePost = false;
  int commentCount;

  CommentWidget({
    Key? key,
    required this.postId,
    required this.isReelScreen,
    required this.commentIdToHighlight,
    this.replyIdToHighlight,
    this.scrollOffset,
    this.isSinglePost = false,
    this.commentCount = 0,
  }) : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _commentController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> commentKey = GlobalKey<FormState>();
  final FocusNode _commentFocusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  File? _mediaFile;
  int? _replyingCommentId;
  String? _replyingToUsername;
  bool isLiked = false;
  bool showReply = false;
  CommentProvider? commentProvider;
  ReplyProvider? replyProvider;

  int _limit = 10;
  int _offset = 0;
  int _replyOffset = 0;
  bool _isLoadingMore = false;
  bool showMore = false;
  int indexIncreament = 0;
  Map<String, GlobalKey> commentKeys = {}; // For comment keys
  //Map<String, Map<String, GlobalKey>> replyKeys =
  //   {}; // For reply keys (nested map for each comment's replies)
  bool replyVisible = false;
  Map<String, GlobalKey<State<StatefulWidget>>> replyKeys = {};

  @override
  void initState() {
    super.initState();
    commentProvider = Provider.of<CommentProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //debugger();
      if (widget.commentIdToHighlight != 'null') {
        _fetchAndScrollToComment(int.parse(widget.commentIdToHighlight));
        if (widget.replyIdToHighlight != 'null') {}
      } else {
        fetchingData();
      }
    });
  }

  void _fetchAndScrollToComment(int commentId) async {
    // Determine the offset/page where the comment resides
    //debugger();
    final data = await commentProvider!.initializeComments(
        widget.postId, widget.isReelScreen,
        limit: _limit, offset: widget.scrollOffset!);
    // Scroll to the specific comment
    // _scrollToBottom();
    _scrollToComment(commentId);
    if (widget.replyIdToHighlight != 'null') {
      _fetchAndScrollToRely(commentId);
    }
  }

  void _fetchAndScrollToRely(int commentId) async {
    // Determine the offset/page where the comment resides
    await replyProvider!.initializeReply(commentId, widget.isReelScreen,
        limit: _limit, offset: widget.scrollOffset!);

    await replyProvider!.toggleReplyVisibility(commentId, context);

    // Scroll to the specific comment
    //_scrollToBottom();
  }

  void _scrollToComment(int? commentID) {
    if (commentProvider!.commentKeys != null)
      final commentKey = commentProvider?.commentKeys[commentID];
    //debugger();
    if (commentKey != null) {
      final context = commentKey?.currentContext;
      //if (context != null) {
      final renderBox =
          commentKey!.currentContext!.findRenderObject() as RenderBox?;

      //final renderBox = context.findRenderObject() as RenderBox?;
      final position = renderBox?.localToGlobal(Offset.zero);

      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              // _scrollController.position.maxScrollExtent,
              _scrollController.offset + position!.dy, // Adjust as needed
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      });
      //Scroll to the comment position
    }
  }

  void _scrollToReply(int replyId) {
    final replyKey = replyKeys[replyId.toString()];
    if (replyKey != null) {
      final context = replyKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        final position = renderBox?.localToGlobal(Offset.zero);

        // Scroll to the reply position
        if (position != null && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.offset + position.dy, // Adjust as needed
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void fetchingData() async {
    final data = await commentProvider!.initializeComments(
        widget.postId, widget.isReelScreen,
        limit: _limit, offset: _offset);
    print("Offset of Comments ${_offset}");

    _scrollToBottom();
  }

  void _scrollToBottom() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void loadReplies(int commentId) async {
    try {
      await Provider.of<ReplyProvider>(context, listen: false)
          .fetchReplies(commentId, limit: _limit, offset: _replyOffset);
      print("Replies fetched successfully!");
    } catch (e) {
      print("Error loading replies: $e");
    }
  }

  void _addComment(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final content = _commentController.text.trim();
      // final keywords = RegExp(r"#\w+")
      //     .allMatches(content)
      //     .map((match) => match.group(0)!)
      //     .toList();
      if (_replyingCommentId != null) {
        //its a reply comment
        Provider.of<ReplyProvider>(context, listen: false).replyComment(
            _replyingCommentId!,
            content: content,
            //keywords:keywords,
            media: _mediaFile,
            context: context,
            widget.isReelScreen);
      } else {
        // Its a new comment
        commentProvider!.addComment(
            widget.postId,
            content: content,
            //keywords:keywords,
            media: _mediaFile,
            context: context,
            widget.isReelScreen);
        setState(() {});
      }

      // Clear input after adding the comment
      _commentController.clear();
      if (mounted)
        setState(() {
          _mediaFile = null;
          _replyingCommentId = null;
          _replyingToUsername = null;
        });
    }
  }

  void _replyToComment(int commentId, String username) {
    if (mounted)
      setState(() {
        _replyingCommentId = commentId;
        _replyingToUsername = username;
        _commentController.text = "@$username ";
      });
    _commentFocusNode.requestFocus();
  }

  void _selectMedia() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted)
        setState(() {
          _mediaFile = File(pickedFile.path);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.white, borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: _buildViewCommentsSection(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildAddCommentSection(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildViewCommentsSection() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReplyProvider()),
      ],
      child: Column(
        children: [
          if (!widget.isSinglePost) ...[
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            color: AppColors.darkGreenColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "London",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Text("740k posts about this place",
                                  style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                          fontSize: 8,
                                          color: AppColors.lightGreyColor,
                                          fontWeight: FontWeight.normal)))
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          CupertinoIcons.xmark,
                          size: 10,
                          weight: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    "${widget.commentCount} Comments",
                    style: GoogleFonts.inter(
                        textStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const Divider(thickness: 1, color: Colors.grey),
              ],
            )
          ],
          Expanded(
            child: Consumer<CommentProvider>(
              builder: (context, commentProvider, child) {
                if (commentProvider.isCommentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final comments = commentProvider.comments;
                if (comments.isEmpty) {
                  return const Center(
                    child: Text("No comments available."),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: comments.length +
                            (commentProvider.hasNextPage ? 1 : 0) +
                            (commentProvider.hasPreviousPage
                                ? 1
                                : 0), // indexIncreament-(commentProvider.hasNextPage?1:0),
                        itemBuilder: (context, index) {
                          //    debugger();
                          if (index == 0 && commentProvider.hasPreviousPage) {
                            return Center(
                              key: commentProvider
                                  ?.commentKeys[comments[index].id],
                              child: GestureDetector(
                                  onTap: () {
                                    print("Previous Comment called");
                                    commentProvider.loadPreviousComments(
                                        widget.postId,
                                        isReel: widget.isReelScreen,
                                        int.parse(widget.commentIdToHighlight),
                                        _limit);
                                  },
                                  child: commentProvider.isLoading
                                      ? CircularProgressIndicator(
                                          color: AppColors.greyColor)
                                      : Text(
                                          'Show Previous Comments',
                                          style: GoogleFonts.publicSans(
                                            textStyle: TextStyle(
                                              color: AppColors
                                                  .viewMoreCommentColor,
                                              fontSize: 8,
                                            ),
                                          ),
                                        )),
                            );
                          }

                          //index == comments.length+(commentProvider.hasNextPage? 0 : 1)

                          if (index ==
                                  comments.length +
                                      (commentProvider.hasPreviousPage
                                          ? 1
                                          : 0) &&
                              commentProvider.hasNextPage) {
                            return Center(
                                child: GestureDetector(
                              onTap: () {
                                commentProvider.loadNextComments(widget.postId,
                                    isReel: widget.isReelScreen);
                              },
                              child: commentProvider.isLoading
                                  ? CircularProgressIndicator(
                                      color: AppColors.greyColor)
                                  : Text(
                                      'Show More Comments',
                                      style: GoogleFonts.publicSans(
                                        textStyle: TextStyle(
                                          color: AppColors.viewMoreCommentColor,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                            ));
                          }
                          final GlobalKey iconKey = GlobalKey();
                          final comment = comments[index -
                              (commentProvider.hasPreviousPage ? 1 : 0)];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundImage: NetworkImage(
                                                      comment.avatarUrl == null
                                                          ? comment.avatarUrl
                                                          : AppUtils.userImage),
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                              comment.username ??
                                                                  '',
                                                              style: GoogleFonts
                                                                  .publicSans(
                                                                textStyle: const TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColors
                                                                        .blackColor),
                                                              )),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                              comment.timeAgo ??
                                                                  '',
                                                              style: GoogleFonts
                                                                  .publicSans(
                                                                textStyle: const TextStyle(
                                                                    fontSize: 8,
                                                                    color: AppColors
                                                                        .lightGrey),
                                                              )),
                                                        ],
                                                      ),
                                                      Text(
                                                          comment.commentText ??
                                                              '',
                                                          style: GoogleFonts
                                                              .publicSans(
                                                            textStyle:
                                                                TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color: AppColors
                                                                  .black,
                                                            ),
                                                          )),
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () =>
                                                                _replyToComment(
                                                                    comment.id,
                                                                    comment
                                                                        .username),
                                                            child: Text("Reply",
                                                                style: GoogleFonts
                                                                    .publicSans(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontSize: 8,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColors
                                                                        .commentReplyColor,
                                                                  ),
                                                                )),
                                                          ),
                                                          SizedBox(
                                                            width: 20,
                                                          ),
                                                          comment.replyCount > 0
                                                              ? !comment
                                                                      .isReplyVisible
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        Provider.of<ReplyProvider>(context, listen: false).toggleReplyVisibility(
                                                                            comment.id,
                                                                            context);
                                                                        // final replyProvider =
                                                                        //     Provider.of<
                                                                        //             ReplyProvider>(
                                                                        //         context,
                                                                        //         listen:
                                                                        //             false);
                                                                        // replyProvider
                                                                        //     .fetchReplies(
                                                                        //         comment
                                                                        //             .id);
                                                                        // setState(() {
                                                                        //   comment.isReplyVisible =
                                                                        //       !comment
                                                                        //           .isReplyVisible;
                                                                        // });
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                0.3,
                                                                            width:
                                                                                12,
                                                                            color:
                                                                                AppColors.commentReplyColor,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                2,
                                                                          ),
                                                                          Text(
                                                                            "View Reply ${comment.replyCount.toString()}",
                                                                            style: GoogleFonts.publicSans(
                                                                                textStyle: TextStyle(
                                                                              color: AppColors.viewMoreCommentColor,
                                                                              fontSize: 8,
                                                                            )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : Container()
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (!comment
                                                                .isLiked) {
                                                              await commentProvider
                                                                  .likeComment(
                                                                comment.id,
                                                                context,
                                                              );
                                                            } else {
                                                              await commentProvider
                                                                  .dislikeComment(
                                                                comment.id,
                                                                0,
                                                                context,
                                                              );
                                                            }
                                                          },
                                                          child: Icon(
                                                            comment.isLiked
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border,
                                                            size: 18,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                            '${comment.likeCount}', // Display the like count
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                    if (false) ...[
                                                      GestureDetector(
                                                        key:
                                                            iconKey, // Unique key for dynamic positioning
                                                        onTap: () {
                                                          _showOptionsMenu(
                                                            context,
                                                            iconKey,
                                                            comment,
                                                          );
                                                        },
                                                        child: Icon(
                                                            Icons.more_vert,
                                                            size: 20),
                                                      ),
                                                    ]
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (comment.isReplyVisible)
                                        Consumer<ReplyProvider>(
                                          builder:
                                              (context, replyProvider, child) {
                                            final replies =
                                                replyProvider.replies;
                                            final isLoading =
                                                replyProvider.isCommentLoading;
                                            final nextOffset =
                                                replyProvider.replyNextOffset;

                                            if (isLoading && replies.isEmpty) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }

                                            if (replies.isEmpty) {
                                              return const Text(
                                                  "No replies available.");
                                            }
                                            //   debugger();

                                            return ListView.builder(
                                              key: replyKeys[
                                                  widget.replyIdToHighlight],
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: replies.length +
                                                  (replyProvider.hasNextPage
                                                      ? 1
                                                      : 0 +
                                                          (comment.replyCount >
                                                                      0 &&
                                                                  index < 10
                                                              ? 1
                                                              : 0)),
                                              itemBuilder:
                                                  (context, replyIndex) {
                                                if (replyIndex == 0 &&
                                                    replyProvider
                                                        .hasPreviousPage) {
                                                  return Center(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        replyProvider
                                                            .loadPreviousReply(
                                                                int.parse(widget
                                                                    .commentIdToHighlight),
                                                                10,
                                                                isReel: widget
                                                                    .isReelScreen);
                                                      },
                                                      child: commentProvider
                                                              .isLoading
                                                          ? CircularProgressIndicator(
                                                              color: AppColors
                                                                  .greyColor)
                                                          : Text(
                                                              'Show Previous Reply',
                                                              style: GoogleFonts
                                                                  .publicSans(
                                                                textStyle:
                                                                    TextStyle(
                                                                  color: AppColors
                                                                      .viewMoreCommentColor,
                                                                  fontSize: 8,
                                                                ),
                                                              )),
                                                    ),
                                                  );
                                                }
                                                if (replyIndex ==
                                                        replies.length &&
                                                    comment.replyCount > 0) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 40.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (replyIndex ==
                                                                replies.length +
                                                                    (replyProvider
                                                                            .hasPreviousPage
                                                                        ? 1
                                                                        : 0) &&
                                                            replyProvider
                                                                .hasNextPage) ...[
                                                          Center(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                replyProvider
                                                                    .loadNextReply(
                                                                        comment
                                                                            .id);
                                                                // replyProvider.fetchReplies(
                                                                //   comment.id,
                                                                //   offset: nextOffset,
                                                                // );
                                                              },
                                                              child: replyProvider
                                                                      .isCommentLoading
                                                                  ? CircularProgressIndicator(
                                                                      color: AppColors
                                                                          .greyColor)
                                                                  : Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              0.3,
                                                                          width:
                                                                              12,
                                                                          color:
                                                                              AppColors.commentReplyColor,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        Text(
                                                                          'View more replies',
                                                                          style:
                                                                              GoogleFonts.publicSans(
                                                                            textStyle:
                                                                                TextStyle(
                                                                              color: AppColors.viewMoreCommentColor,
                                                                              fontSize: 8,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                            ),
                                                          ),
                                                           SizedBox(
                                                          width: 18,
                                                        ),
                                                        ],
                                                       
                                                        comment.isReplyVisible
                                                            ? GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  Provider.of<ReplyProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .toggleReplyVisibility(
                                                                          comment
                                                                              .id,
                                                                          context);
                                                                  // final replyProvider =
                                                                  //     Provider.of<
                                                                  //             ReplyProvider>(
                                                                  //         context,
                                                                  //         listen:
                                                                  //             false);
                                                                  // replyProvider
                                                                  //     .fetchReplies(
                                                                  //         comment
                                                                  //             .id);
                                                                  // setState(() {
                                                                  //   comment.isReplyVisible =
                                                                  //       !comment
                                                                  //           .isReplyVisible;
                                                                  // });
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child: Text(
                                                                  "Hide",
                                                                  style: GoogleFonts
                                                                      .publicSans(
                                                                          textStyle:
                                                                              TextStyle(
                                                                    color: AppColors
                                                                        .commentReplyColor,
                                                                    fontSize: 8,
                                                                  )),
                                                                ),
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                  );
                                                }

                                                final reply = replies[
                                                    replyIndex -
                                                        (replyProvider
                                                                .hasPreviousPage
                                                            ? 1
                                                            : 0)];
                                                final GlobalKey replyiconKey =
                                                    GlobalKey();

                                                replyKeys[reply.id.toString()] =
                                                    replyiconKey;
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 40.0, top: 10),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 10,
                                                        backgroundImage: NetworkImage(
                                                            reply.replierImage ==
                                                                    null
                                                                ? reply
                                                                    .replierImage
                                                                : AppUtils
                                                                    .userImage),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  reply
                                                                      .replierName,
                                                                  style: GoogleFonts
                                                                      .publicSans(
                                                                    textStyle: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: AppColors
                                                                            .blackColor),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text('6H',
                                                                    style: GoogleFonts
                                                                        .publicSans(
                                                                      textStyle: const TextStyle(
                                                                          fontSize:
                                                                              8,
                                                                          color:
                                                                              AppColors.lightGrey),
                                                                    )),
                                                              ],
                                                            ),
                                                            Text(
                                                              reply.content,
                                                              style: GoogleFonts
                                                                  .publicSans(
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (!reply
                                                                      .isReplyLiked) {
                                                                    await replyProvider.likeReply(
                                                                        reply
                                                                            .id,
                                                                        comment
                                                                            .id,
                                                                        context);
                                                                    setState(
                                                                        () {
                                                                      replyProvider
                                                                          .fetchReplies(
                                                                              comment.id);
                                                                    });
                                                                  } else {
                                                                    await replyProvider.dislikeReply(
                                                                        comment
                                                                            .id,
                                                                        reply
                                                                            .id,
                                                                        context);
                                                                    setState(
                                                                        () {
                                                                      replyProvider
                                                                          .fetchReplies(
                                                                              comment.id);
                                                                    });
                                                                  }
                                                                  print(
                                                                      "Liked Triggered with Reply ID : ${reply.id}");
                                                                },
                                                                child: Icon(
                                                                  reply.isReplyLiked
                                                                      ? Icons
                                                                          .favorite
                                                                      : Icons
                                                                          .favorite_border,
                                                                  size: 20,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                  '${reply.replyLikeCount}', // Display the reply like count
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                      fontSize:
                                                                          12)),
                                                            ],
                                                          ),
                                                          if(false)
                                                          GestureDetector(
                                                            key:
                                                                replyiconKey, // Unique key for dynamic positioning
                                                            onTap: () {
                                                              _showReplyOptionsMenu(
                                                                  context,
                                                                  replyiconKey,
                                                                  comment,
                                                                  reply);
                                                            },
                                                            child: Icon(
                                                                Icons.more_vert,
                                                                size: 20),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 70,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentSection(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xffDADADA), width: 0.5),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: Image.network(
                  AppUtils.userImage,
                  width: 48,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  height: 40,
                  child: TextFormField(
                    controller: _commentController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Comment cannot be empty!";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      hintStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0.5, // Border width
                          color: Color(0xffDADADA), // Border color
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _addComment(
                            context); // Replace with your comment submission logic
                      }
                    },
                  ),
                ),
              ),
              // IconButton(
              //   icon: const Icon(Icons.image),
              //   onPressed: _selectMedia,
              // ),
              // IconButton(
              //   icon: const Icon(Icons.send),
              //   onPressed: () => _addComment(context),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(
    BuildContext context,
    GlobalKey key,
    Comment comment,
  ) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + renderBox.size.height,
      offset.dx + renderBox.size.width,
      offset.dy,
    );

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
    ).then((value) {
      if (value == 'delete') {
        Provider.of<CommentProvider>(context, listen: false).deleteComment(
            comment.id.toString(), context, widget.postId, widget.isReelScreen);
      } else if (value == 'edit') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Edit functionality not implemented.")),
        );
      }
    });
  }

  //Comment  Reply Option
  void _showReplyOptionsMenu(
    BuildContext context,
    GlobalKey key,
    Comment comment,
    Reply reply,
  ) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + renderBox.size.height,
      offset.dx + renderBox.size.width,
      offset.dy,
    );

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
    ).then((value) {
      if (value == 'delete') {
        Provider.of<ReplyProvider>(context, listen: false)
            .deleteCommentReply(reply.id, comment.id, context);
      } else if (value == 'edit') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Edit functionality not implemented.")),
        );
      }
    });
  }
}
