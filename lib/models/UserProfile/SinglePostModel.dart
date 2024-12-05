class Post {
  final String status;
  final PostDetails posts;

  Post({required this.status, required this.posts});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      status: json['status'],
      posts: PostDetails.fromJson(json['posts']),
    );
  }
}

class PostDetails {
  final int id;
  final String post;
  final List<Tag> tags;
  final List<Keyword> keywords;
  final List<Media> media;
  final User user;
  final String privacy;
  final String createdAt;
  final String updatedAt;
  final int likesCount;
  final int commentsCount;
  bool isLiked;

  PostDetails({
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
    required this.isLiked
  });

  factory PostDetails.fromJson(Map<String, dynamic> json) {
    var tagList = json['tags'] as List;
    var keywordList = json['keywords'] as List;
    var mediaList = json['media'] as List;

    return PostDetails(
      id: json['id'],
      post: json['post'],
      tags: tagList.map((tag) => Tag.fromJson(tag)).toList(),
      keywords: keywordList.map((keyword) => Keyword.fromJson(keyword)).toList(),
      media: mediaList.map((media) => Media.fromJson(media)).toList(),
      user: User.fromJson(json['user']),
      privacy: json['privacy'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      isLiked: json['is_liked'],
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

  Keyword({required this.id, required this.word});

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

  Media({required this.id, required this.mediaType, required this.file});

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
  final String? profileImage; // Added profile image field

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profileImage,
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
