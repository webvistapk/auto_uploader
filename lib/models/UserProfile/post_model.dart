class PostModel {
  final String status;
  final List<Post> posts;
  final int totalCount;
  final bool hasNextPage;
  final dynamic nextOffset;

  PostModel({
    required this.status,
    required this.posts,
    required this.totalCount,
    required this.hasNextPage,
    this.nextOffset,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      status: json['status']??'',
      posts: List<Post>.from(json['posts'].map((post) => Post.fromJson(post))),
      totalCount: json['total_count']??0,
      hasNextPage: json['has_next_page']??'',
      nextOffset: json['next_offset']??'',
    );
  }
}

class Post {
  final int id;
  final String post;
  final List<Tag> tags;
  final List<Keyword> keywords;
  final List<Media> media;
  final User user;
  final String privacy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.post,
    required this.tags,
    required this.keywords,
    required this.media,
    required this.user,
    required this.privacy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']??0,
      post: json['post']??'',
      tags: List<Tag>.from(json['tags'].map((tag) => Tag.fromJson(tag))),
      keywords: List<Keyword>.from(json['keywords'].map((keyword) => Keyword.fromJson(keyword))),
      media: List<Media>.from(json['media'].map((media) => Media.fromJson(media))),
      user: User.fromJson(json['user']),
      privacy: json['privacy']??'',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}
