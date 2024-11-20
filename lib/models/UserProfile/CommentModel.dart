class Comment {
  final String username;
  final String avatarUrl;
  final String commentText;
  final List<Reply> replies;
  final String timeAgo;

  Comment({
    required this.username,
    required this.avatarUrl,
    required this.commentText,
    this.replies = const [],
    required this.timeAgo,
  });
}

class Reply {
  final String username;
  final String avatarUrl;
  final String replyText;
  final String timeAgo;

  Reply({
    required this.username,
    required this.avatarUrl,
    required this.replyText,
    required this.timeAgo,
  });
}
