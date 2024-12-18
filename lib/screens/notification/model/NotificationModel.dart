class NotificationResponse {
  final String status;
  final List<NotificationModel> notifications;
  final int totalCount;
  final bool hasNextPage;
  final int? nextOffset;

  NotificationResponse({
    required this.status,
    required this.notifications,
    required this.totalCount,
    required this.hasNextPage,
    this.nextOffset,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'],
      notifications: (json['notifications'] as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList(),
      totalCount: json['total_count'],
      hasNextPage: json['has_next_page'],
      nextOffset: json['next_offset'],
    );
  }
}

class NotificationModel {
  final int id;
  final Actor actor;
  final String action;
  final Post? post;
  final Reel? reel;
  final Comment? comment;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.actor,
    required this.action,
    this.post,
    this.reel,
    this.comment,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      actor: Actor.fromJson(json['actor']['result']),
      action: json['action'],
      post: json['post']['result'] != null
          ? Post.fromJson(json['post']['result'])
          : null,
      reel: json['reel']['result'] != null
          ? Reel.fromJson(json['reel']['result'])
          : null,
      comment: json['comment']['result'] != null
          ? Comment.fromJson(json['comment']['result'])
          : null,
      createdAt: json['created_at'],
    );
  }
}

class Actor {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profileImage;

  Actor({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
    );
  }
}

class Post {
  final int id;
  final String post;

  Post({required this.id, required this.post});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      post: json['post'],
    );
  }
}

class Reel {
  final int id;
  final String file;

  Reel({required this.id, required this.file});

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'],
      file: json['file'],
    );
  }
}

class Comment {
  final int id;
  final String content;

  Comment({required this.id, required this.content});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
);
}
}