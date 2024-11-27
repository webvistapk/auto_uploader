class Comment {
  final int id;
  final String username;
  final String avatarUrl;
  final String commentText;
  final List<Reply> replies;
  final String timeAgo;

  Comment({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.commentText,
    required this.replies,
    required this.timeAgo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      username: json['user']['username'],
      avatarUrl: json['user']['profile_image'] ?? '',
      commentText: json['content'],
      timeAgo: json['created_at'],
      replies: [], // Populate replies if your API supports them
    );
  }
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

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      username: json['username'],
      avatarUrl: json['profile_image'] ?? '',
      replyText: json['content'],
      timeAgo: json['created_at'],
    );
  }
}