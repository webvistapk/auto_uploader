class NotificationModel {
  final int id;
  final String action;
  final Actor actor;
  final Target target;
  final Reel? reel;
  final Post? post;
  final Comment? comment;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.action,
    required this.actor,
    required this.target,
    this.reel,
    this.post,
    this.comment,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      action: json['action'],
      actor: Actor.fromJson(json['actor']),
      target: Target.fromJson(json['target']),
      reel: json['reel'] != null ? Reel.fromJson(json['reel']) : null,
      post: json['post'] != null ? Post.fromJson(json['post']) : null,
      comment: json['comment'] != null ? Comment.fromJson(json['comment']) : null,
      createdAt: DateTime.parse(json['created_at']),
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

class Target {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profileImage;

  Target({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
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
