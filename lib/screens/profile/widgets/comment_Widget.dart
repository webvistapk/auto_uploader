import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  CommentWidget({
    Key? key,
    required this.postId,
    required this.isReelScreen,
    required this.commentIdToHighlight,
    this.replyIdToHighlight,
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
    if (widget.commentIdToHighlight != 'null') {
      _fetchAndScrollToComment(int.parse(widget.commentIdToHighlight!));

      setState(() {
      indexIncreament += 1;
        
      });
    } else {
      fetchingData();
    }
  });
}


  void _fetchAndScrollToComment(int commentId) async {
    // Determine the offset/page where the comment resides
    int pageContainingComment = await commentProvider!.findPageForComment(
      postId: widget.postId,
      commentId: commentId,
      limit: _limit,
      isReel: widget.isReelScreen
    );
    // Adjust offset and fetch comments for that page
    _offset = pageContainingComment * _limit;

    // Scroll to the specific comment
    _scrollToComment(commentId.toString());

    fetchingData();
  }

  void _scrollToComment(String? commentID) {
    final commentKey = commentKeys[commentID];
    if (commentKey != null) {
      final context = commentKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        final position = renderBox?.localToGlobal(Offset.zero);

        // Scroll to the comment position
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
    final data = await commentProvider!.fetchComments(
        widget.postId, widget.isReelScreen,
        limit: _limit, offset: _offset);

    if (data != null && widget.commentIdToHighlight != 'null') {
      _scrollToBottom();
    }
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
        Provider.of<CommentProvider>(context, listen: false).addComment(
            widget.postId,
            content: content,
            //keywords:keywords,
            media: _mediaFile,
            context: context,
            widget.isReelScreen);
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
    //print("WIDGET COMMENT SECTION ${widget.scrollCommentId}");

    return Stack(
      children: [
        //widget.isUsedSingle
        //?
        // _buildViewCommentsSection(),

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
    );
  }

  Widget _buildViewCommentsSection() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReplyProvider()),
      ],
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        CupertinoIcons.xmark,
                        size: 20,
                        weight: 25,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1, color: Colors.grey),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: comments.length +
                      (commentProvider.nextOffset != -1 ? 1 : 0) +
                      indexIncreament,
                  itemBuilder: (context, index) {
                    print("index ${index}");
                    if (index == 0 && widget.commentIdToHighlight != 'null' ||
                        commentProvider.previousOffset < 0) {
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            commentProvider.loadPreviousComments(widget.postId,isReel:widget.isReelScreen,
                                int.parse(widget.commentIdToHighlight), _limit);
                          },
                          child: commentProvider.isLoading
                              ? CircularProgressIndicator(
                                  color: AppColors.greyColor)
                              : Text(
                                  'Show Previous Comments',
                                  style: TextStyle(color: Colors.black),
                                ),
                        ),
                      );
                    }
                    if (index == comments.length + indexIncreament) {
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            commentProvider.loadNextComments(widget.postId,isReel:widget.isReelScreen);
                          },
                          child: commentProvider.isLoading
                              ? CircularProgressIndicator(
                                  color: AppColors.greyColor)
                              : Text(
                                  'Show More Comments',
                                  style: TextStyle(color: Colors.black),
                                ),
                        ),
                      );
                    }
                    final GlobalKey iconKey = GlobalKey();
                    final comment = comments[index - indexIncreament];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(
                                                comment.avatarUrl == null
                                                    ? comment.avatarUrl
                                                    : AppUtils.userImage),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comment.username ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  comment.commentText ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _replyToComment(
                                                              comment.id,
                                                              comment.username),
                                                      child: Text(
                                                        "Reply",
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blue[600],
                                                          fontSize: 9,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    comment.replyCount > 0
                                                        ? GestureDetector(
                                                            onTap: () async {
                                                              // Provider.of<ReplyProvider>(
                                                              //         context,
                                                              //         listen:
                                                              //             false)
                                                              //     .toggleReplyVisibility(
                                                              //         comment.id);
                                                              final replyProvider =
                                                                  Provider.of<
                                                                          ReplyProvider>(
                                                                      context,
                                                                      listen:
                                                                          false);
                                                              replyProvider
                                                                  .fetchReplies(
                                                                      comment
                                                                          .id);
                                                              setState(() {
                                                                comment.isReplyVisible =
                                                                    !comment
                                                                        .isReplyVisible;
                                                              });
                                                            },
                                                            child: Text(
                                                              comment.isReplyVisible
                                                                  ? "Hide Replies"
                                                                  : "View Reply ${comment.replyCount.toString()}",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .blue[600],
                                                                fontSize: 9,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                               
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (!comment.isLiked) {
                                                        await commentProvider
                                                            .likeComment(
                                                                comment.id,
                                                                context,
                                                                false);
                                                      } else {
                                                        await commentProvider
                                                            .dislikeComment(
                                                                comment.id,
                                                                0,
                                                                context,
                                                                false);
                                                      }
                                                    },
                                                    child: Icon(
                                                      comment.isLiked
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      size: 20,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                      '${comment.likeCount}', // Display the like count
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12)),
                                                ],
                                              ),
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
                                                child: Icon(Icons.more_vert,
                                                    size: 20),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (comment.isReplyVisible)
                                  Consumer<ReplyProvider>(
                                    builder: (context, replyProvider, child) {
                                      final replies = replyProvider.replies;
                                      final isLoading =
                                          replyProvider.isCommentLoading;
                                      final nextOffset =
                                          replyProvider.replyNextOffset;

                                      if (isLoading && replies.isEmpty) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (replies.isEmpty) {
                                        return const Text(
                                            "No replies available.");
                                      }

                                      return ListView.builder(
                                        key: replyKeys[widget.replyIdToHighlight],
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: replies.length +
                                            (nextOffset != -1 ? 1 : 0),
                                        itemBuilder: (context, replyIndex) {
                                          if (replyIndex == replies.length) {
                                            return Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  replyProvider.fetchReplies(
                                                    comment.id,
                                                    offset: nextOffset,
                                                  );
                                                },
                                                child: replyProvider
                                                        .isCommentLoading
                                                    ? CircularProgressIndicator(
                                                        color:
                                                            AppColors.greyColor)
                                                    : Text(
                                                        'Show More Replies',
                                                        style: TextStyle(
                                                            color: Colors.black),
                                                      ),
                                              ),
                                            );
                                          }

                                          final reply = replies[replyIndex];
                                          final GlobalKey replyiconKey =
                                              GlobalKey();
                                          
                                          replyKeys[reply.id.toString()] =
                                              replyiconKey;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 40.0, top: 10),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundImage: NetworkImage(
                                                      reply.replierImage == null
                                                          ? reply.replierImage
                                                          : AppUtils.userImage),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        reply.replierName,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        reply.content,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
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
                                                          onTap: () async {
                                                            if (!reply
                                                                .isReplyLiked) {
                                                              await replyProvider
                                                                  .likeReply(
                                                                      reply.id,
                                                                      comment
                                                                          .id,
                                                                      context);
                                                              setState(() {
                                                                replyProvider
                                                                    .fetchReplies(
                                                                        comment
                                                                            .id);
                                                              });
                                                            } else {
                                                              await replyProvider
                                                                  .dislikeComment(
                                                                      comment
                                                                          .id,
                                                                      reply.id,
                                                                      context,
                                                                      true);
                                                              setState(() {
                                                                replyProvider
                                                                    .fetchReplies(
                                                                        comment
                                                                            .id);
                                                              });
                                                            }
                                                            print(
                                                                "Liked Triggered with Reply ID : ${reply.id}");
                                                          },
                                                          child: Icon(
                                                            reply.isReplyLiked
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border,
                                                            size: 20,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                            '${reply.replyLikeCount}', // Display the reply like count
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize: 12)),
                                                      ],
                                                    ),
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
    );
  }

  Widget _buildAddCommentSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(AppUtils.userImage),
            ),
            const SizedBox(width: 10),
            Expanded(
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
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _selectMedia,
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _addComment(context),
            ),
          ],
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
        Provider.of<CommentProvider>(context, listen: false)
            .deleteCommentReply(reply.id, comment.id, context);
      } else if (value == 'edit') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Edit functionality not implemented.")),
        );
      }
    });
  }
}
