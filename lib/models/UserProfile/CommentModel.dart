import 'package:flutter/cupertino.dart';

class CommentModel {
  String status;
  List<Comment> comments;
  int totalCount;
  bool hasNextPage;
  int nextOffset;

  CommentModel({
    required this.status,
    required this.comments,
    required this.totalCount,
    required this.hasNextPage,
    required this.nextOffset,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      status: json['status'],
      comments: (json['comments'] as List)
          .map((item) => Comment.fromJson(item))
          .toList(),
      totalCount: json['total_count'],
      hasNextPage: json['has_next_page'],
      nextOffset: json['next_offset']??0,
    );
  }
}

class Comment {
  final int id;
  final String username;
  final String avatarUrl;
  final String commentText;
  final List<Reply> replies;
  final String timeAgo;
   bool isLiked;
   int likeCount;
   int replyCount;
   bool isReplyVisible;
   bool isReplyLoaded;
   ValueNotifier<bool> isReplyVisibleNotifier;
  ValueNotifier<bool> isReplyLoadedNotifier;

  Comment({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.commentText,
    required this.replies,
    required this.timeAgo,
    required this.isLiked,
    required this.likeCount,
    required this.replyCount,
     this.isReplyVisible=false,
     this.isReplyLoaded=false,
  }): isReplyVisibleNotifier = ValueNotifier(isReplyVisible),
        isReplyLoadedNotifier = ValueNotifier(isReplyLoaded);

  

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      username: json['user']['username'],
      avatarUrl: json['user']['profile_image'] ?? '',
      commentText: json['content'],
      timeAgo: json['created_at'],
      replies: [], // Populate replies if your API supports them
      isLiked: json['is_liked'],
      likeCount: json['likes_count'],
      replyCount: json['replies_count'],
      isReplyVisible: false,
      isReplyLoaded: false,
    );
  }
}

class ReplyModel {
  String status;
  List<Reply> reply;
  int totalCount;
  bool hasNextPage;
  int nextOffset;

  ReplyModel({
    required this.status,
    required this.reply,
    required this.totalCount,
    required this.hasNextPage,
    required this.nextOffset,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      status: json['status'],
      reply: (json['reply'] as List)
          .map((item) => Reply.fromJson(item))
          .toList(),
      totalCount: json['total_count'],
      hasNextPage: json['has_next_page'],
      nextOffset: json['next_offset']??0,
    );
  }
}

class Reply {
 final int id;
  final String content;
  final String replierName;
  final String replierImage;
  bool isReplyLiked;
  int replyLikeCount;

  Reply({
    required this.id,
    required this.content,
    required this.replierName,
    required this.replierImage,
    required this.isReplyLiked,
    required this.replyLikeCount

  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'],
      content: json['content'],
      replierName: json['user']['username'],
      replierImage: json['user']['profile_image']??'',
      replyLikeCount: json['likes_count'],
      isReplyLiked: json['is_liked']

    );
  }
}