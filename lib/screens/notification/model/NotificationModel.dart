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
      status: json['status'] as String,
      notifications: (json['notifications'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      totalCount: json['total_count'] as int,
      hasNextPage: json['has_next_page'] as bool,
      nextOffset: json['next_offset'] as int?,
    );
  }
}


class NotificationModel {
  final int id;
  final Actor? actor;
  final String action;
  final Post? post;
  final Reel? reel;
  final Comment? comment;
  final Reply? reply;
  final Vote? vote;
  final Target? target;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    this.actor,
    required this.action,
    this.post,
    this.reel,
    this.comment,
    this.reply,
    this.vote,
    this.target,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      actor: json['actor']?['result'] != null
          ? Actor.fromJson(json['actor']['result'])
          : null,
      action: json['action'] as String,
      post: json['post']?['result'] != null
          ? Post.fromJson(json['post']['result'])
          : null,
      reel: json['reel']?['result'] != null
          ? Reel.fromJson(json['reel']['result'])
          : null,
      comment: json['comment']?['result'] != null
          ? Comment.fromJson(json['comment']['result'])
          : null,
      reply: json['reply'] != null
          ? Reply.fromJson(json['reply'])
          : null,
      vote: json['vote']?['result'] != null
          ? Vote.fromJson(json['vote']['result'])
          : null,
      target: json['target']?['result'] != null
          ? Target.fromJson(json['target']['result'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      profileImage: json['profile_image'] as String?,
    );
  }
}

class Post {
  final int id;
  final String post;

  Post({required this.id, required this.post});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int? ?? 0,
      post: json['post'] as String? ?? '',
    );
  }
}

class Reel {
  final int id;
  final String file;

  Reel({required this.id, required this.file});

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'] as int? ?? 0,
      file: json['file'] as String? ?? '',
    );
  }
}

class Reply {
  final int? offset;
  final int? limit;
  final ReplyResult? result; // Represents the `result` object
  final PostOrReel? postOrReel; // Nullable field for `post_or_reel`

  Reply({
    required this.offset,
    required this.limit,
    this.result,
    this.postOrReel,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      offset: json['offset'] ??0,
      limit: json['limit'] ?? 0,
      result: json['result'] != null
          ? ReplyResult.fromJson(json['result']) // Parse `result` safely
          : null,
      postOrReel: json['post_or_reel'] != null
          ? PostOrReel.fromJson(json['post_or_reel']) // Parse `post_or_reel` safely
          : null,
    );
  }
}
class ReplyResult {
  final int id;
  final String content;

  ReplyResult({
    required this.id,
    required this.content,
  });

  factory ReplyResult.fromJson(Map<String, dynamic> json) {
    return ReplyResult(
      id: json['id'] as int,
      content: json['content'] as String,
    );
  }
}



class PostOrReel {
  final String type;
  final Map<String, dynamic>? data; // Make `data` nullable if needed

  PostOrReel({
    required this.type,
    this.data,
  });

  factory PostOrReel.fromJson(Map<String, dynamic> json) {
    return PostOrReel(
      type: json['type'] as String,
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}


class Comment {
  final int id;
  final String content;

  Comment({required this.id, required this.content});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int? ?? 0,
      content: json['content'] as String? ?? '',
    );
  }
}

class Vote {
  final int id;
  final int poll;

  Vote({required this.id, required this.poll});

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'] as int? ?? 0,
      poll: json['poll'] as int? ?? 0,
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
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
    );
  }
}
