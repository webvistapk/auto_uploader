class FollowerStoriesModel {
  final String status;
  final List<User> users;
  final int totalCount;
  final bool hasNextPage;
  final int? nextOffset;
  final bool hasPreviousPage;
  final int? previousOffset;

  FollowerStoriesModel({
    required this.status,
    required this.users,
    required this.totalCount,
    required this.hasNextPage,
    this.nextOffset,
    required this.hasPreviousPage,
    this.previousOffset,
  });

  factory FollowerStoriesModel.fromJson(Map<String, dynamic> json) {
    return FollowerStoriesModel(
      status: json['status'],
      users: List<User>.from(json['users'].map((user) => User.fromJson(user))),
      totalCount: json['total_count'],
      hasNextPage: json['has_next_page'],
      nextOffset: json['next_offset'],
      hasPreviousPage: json['has_previous_page'],
      previousOffset: json['previous_offset'],
    );
  }
}

class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final List<Story> stories;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.stories,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
      stories: List<Story>.from(json['stories'].map((story) => Story.fromJson(story))),
    );
  }
}

class Story {
  final int id;
  final List<String> tags;
  final List<Media> media;
  final String privacy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int seenCount;

  Story({
    required this.id,
    required this.tags,
    required this.media,
    required this.privacy,
    required this.createdAt,
    required this.updatedAt,
    required this.seenCount,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      tags: List<String>.from(json['tags']),
      media: List<Media>.from(json['media'].map((m) => Media.fromJson(m))),
      privacy: json['privacy'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      seenCount: json['seen_count'],
    );
  }
}

class Media {
  final int id;
  final String mediaType;
  final String file;

  Media({
    required this.id,
    required this.mediaType,
    required this.file,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      mediaType: json['media_type'],
      file: json['file'],
    );
  }
}
