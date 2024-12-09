import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/post/comment_provider.dart';
import 'package:mobile/models/UserProfile/commentBottomSheet.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../controller/services/post/post_provider.dart';
import '../../../models/UserProfile/CommentModel.dart';

class CommentWidget extends StatefulWidget {
  final bool isUsedSingle;
  final bool isReelScreen;
  final String postId;

  CommentWidget(
      {Key? key,
      required this.isUsedSingle,
      required this.postId,
      required this.isReelScreen})
      : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  File? _mediaFile;
  int? _replyingCommentId;
  String? _replyingToUsername;
  bool isLiked = false;
  bool showReply=false;

  @override
  void initState() {
    super.initState();
    print("init state triggered");
    // Fetch comments when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentProvider>(context, listen: false)
          .fetchComments(widget.postId, widget.isReelScreen);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

void loadReplies(int commentId) async {
  try {
    await Provider.of<CommentProvider>(context,listen: false).fetchReplies(commentId);
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
        Provider.of<CommentProvider>(context, listen: false).replyComment(
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
      setState(() {
        _mediaFile = null;
        _replyingCommentId = null;
        _replyingToUsername = null;
      });
    }
  }

  void _replyToComment(int commentId, String username) {
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
      setState(() {
        _mediaFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.isUsedSingle
            ? _buildViewCommentsSection()
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: _buildViewCommentsSection(),
              ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildAddCommentSection(context),
        ),
      ],
    );
  }

  Widget _buildViewCommentsSection() {
    return Consumer<CommentProvider>(
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
            if (widget.isUsedSingle)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Wrap(
                    //   crossAxisAlignment: WrapCrossAlignment.center,
                    //   children: [
                    //     Container(
                    //       height: 50,
                    //       width: 50,
                    //       decoration: BoxDecoration(
                    //         color: Colors.green,
                    //         borderRadius: BorderRadius.circular(25),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     const Text(
                    //       "Person Name",
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
              //height:MediaQuery.of(context).size.height ,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final GlobalKey iconKey = GlobalKey();
                    
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
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                            comment.avatarUrl == null
                                                ? comment.avatarUrl
                                                : AppUtils.userImage),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.username,
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                          //const SizedBox(height: 5),
                                          Text(
                                            comment.commentText,
                                            style: TextStyle(
                                              fontSize: 12,
                                                color:
                                                    Colors.grey[600]),
                                                    
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
                                                      fontSize:9,
                                                      ),
                                                ),
                                              ),
                                               SizedBox(width: 20,),
                                               comment.replyCount>0? GestureDetector(
                                                onTap: ()async{
                                                  setState(() {
                                                    comment.isReplyVisible = !comment.isReplyVisible;
                                                  });
                                                  if(!comment.isReplyLoaded){
                                                    try{
                                                      await Provider.of<CommentProvider>(context,listen: false).fetchReplies(comment.id);
                                                      setState(() {
                                                        comment.isReplyLoaded=true;
                                                      });
                                                    }
                                                    catch(e){
                                                      ToastNotifier.showErrorToast(context, "Error fetching post ${e}");
                                                    }
                                                  }
                                                },
                                                 child: Text(
                                                   comment.isReplyVisible ? "Hide Replies" : "View Reply ${comment.replyCount.toString()}",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.blue[600],
                                                        fontSize: 9,
                                                        ),
                                                  ),
                                               ):Container(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
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
                                              }
                                              else{
                                                await commentProvider.dislikeComment(comment.id, context, false);
                                              }
                                            },
                                            child:  Icon(comment.isLiked?
                                              Icons.favorite:Icons.favorite_border,
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
                              //Reply Section Sttart from here
                              if (comment.replies.isNotEmpty && comment.isReplyVisible)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      NeverScrollableScrollPhysics(),
                                  itemCount: comment.replies.length,
                                  itemBuilder: (context, replyIndex) {
                                   final reply = comment.replies[replyIndex];
                                    final GlobalKey replyiconKey =
                                        GlobalKey();
                    
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 40.0, top: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(
                                                reply.replierImage ==
                                                        null
                                                    ? reply.replierImage
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
                                                Text(
                                                  reply.replierName
                                                      .toString(),
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  reply.content
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: Colors
                                                        .grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _replyToComment(
                                                          comment.id,
                                                          reply
                                                              .replierName),
                                                  child: Text(
                                                    "Reply",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .blue[600],
                                                        fontSize: 9,
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
                                                    onTap: () async {
                                                      if (!reply
                                                          .isReplyLiked) {
                                                        await commentProvider
                                                            .likeComment(reply.id, context, true);}
                                                            else{
                                                              await commentProvider.dislikeComment(reply.id, context, true);
                                                            }
                                                      print("Liked Triggered with Reply ID : ${reply.id}");
                                                    },
                                                    child: Icon(
                                                      reply.isReplyLiked?
                                                      Icons.favorite:Icons.favorite_border,
                                                      size: 20,
                                                      color: 
                                               Colors.grey,
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
          ],
        );
      },
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
