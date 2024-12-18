class PostModel {
  final int id;
  final String post;
  final List<Tag> tags;
  final List<Keyword> keywords;
  final List<Media> media;
  final User user;
  final String privacy;
  final String createdAt;
  final String updatedAt;
   int likesCount;
   int commentsCount;
   bool is_liked;

  PostModel({
    required this.id,
    required this.post,
    required this.tags,
    required this.keywords,
    required this.media,
    required this.user,
    required this.privacy,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.is_liked
  });

  // Factory method to parse JSON data
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      post: json['post'],
      tags: (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList(),
      keywords: (json['keywords'] as List).map((kw) => Keyword.fromJson(kw)).toList(),
      media: (json['media'] as List).map((m) => Media.fromJson(m)).toList(),
      user: User.fromJson(json['user']),
      privacy: json['privacy'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      is_liked: json['is_liked']
    );
  }
}

class Tag {
  final int id;
  final String username;
  final String firstName;
  final String lastName;

  Tag({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}

class Keyword {
  final int id;
  final String word;

  Keyword({
    required this.id,
    required this.word,
  });

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      id: json['id'],
      word: json['word'],
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

class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profileImage; // Add this field

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profileImage, // Make profileImage optional
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'], // Parse the profileImage field
    );
  }
}
