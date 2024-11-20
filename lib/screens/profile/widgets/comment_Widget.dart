import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../common/utils.dart';
import '../../../models/UserProfile/CommentModel.dart';

class CommentWidget extends StatefulWidget {
  bool isUsedSingle;
   CommentWidget({super.key,
    required this.isUsedSingle});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {

  List<Comment> comments = [
    Comment(
      username: 'User',
      avatarUrl: AppUtils.userImage,
      commentText: 'This is a comment.',
      replies: [
        Reply(
          username: 'User2',
          avatarUrl: AppUtils.userImage,
          replyText: 'This is a reply.',
          timeAgo: '2h ago',
        ),
      ],
      timeAgo: '1h ago',
    ),
    Comment(
      username: 'User',
      avatarUrl: AppUtils.userImage,
      commentText: 'This is a comment 2.',
      replies: [
        Reply(
          username: 'User2',
          avatarUrl: AppUtils.userImage,
          replyText: 'This is a reply1.',
          timeAgo: '2h ago',
        ),
        Reply(
          username: 'User3',
          avatarUrl: AppUtils.userImage,
          replyText: 'This is a reply2.',
          timeAgo: '2h ago',
        ),
        Reply(
          username: 'User2',
          avatarUrl: AppUtils.userImage,
          replyText: 'This is a reply3.',
          timeAgo: '2h ago',
        ),
      ],
      timeAgo: '4h ago',
    ),

    Comment(
      username: 'User',
      avatarUrl: AppUtils.userImage,
      commentText: 'This is a comment 2.',
      replies: [
        Reply(
          username: 'User2',
          avatarUrl: AppUtils.userImage,
          replyText: 'This is a reply1.',
          timeAgo: '2h ago',
        ),
        Reply(
          username: 'User3',
          avatarUrl: AppUtils.userImage,
          replyText: 'This is a reply2.',
          timeAgo: '2h ago',
        ),
      ],
      timeAgo: '4h ago',
    ),

    // Add more comments here
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            widget.isUsedSingle?Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Person Name",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Pop Called");
                      Navigator.pop(context);
                    },
                    child: Icon(CupertinoIcons.xmark, size: 20),
                  ),
                ],
              ),
            ):Container(),
            // Title Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "23 Comments",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Divider(thickness: 1, color: Colors.grey.shade300),

            // Comments Section
            Expanded(
              child: ListView.builder(
                itemCount: comments.length, // Replace with your dynamic comment list
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Comment
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(comment.avatarUrl),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.username,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    comment.commentText,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        "Reply",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        comment.timeAgo,
                                        style: TextStyle(color: Colors.grey, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.favorite_border, size: 20, color: Colors.grey),
                          ],
                        ),
                        // Replies Section
                        if (comment.replies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 40.0, top: 10),
                            child: Column(
                              children: comment.replies.map((reply) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundImage: NetworkImage(reply.avatarUrl),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reply.username,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            reply.replyText,
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                "Reply",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                reply.timeAgo,
                                                style: TextStyle(color: Colors.grey, fontSize: 8),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.favorite_border, size: 15, color: Colors.grey),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        Divider(thickness: 1, color: Colors.grey.shade300),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Add Comment Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(AppUtils.userImage),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      // Handle adding the comment
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
