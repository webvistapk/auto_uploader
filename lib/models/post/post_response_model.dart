class PostsResponse {
  final String status;
  final List<Post> posts;
  final int totalCount;
  final bool hasNextPage;
  final int? nextOffset;

  PostsResponse({
    required this.status,
    required this.posts,
    required this.totalCount,
    required this.hasNextPage,
    this.nextOffset,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    return PostsResponse(
      status: json['status'],
      posts:
          (json['posts'] as List).map((post) => Post.fromJson(post)).toList(),
      totalCount: json['total_count'],
      hasNextPage: json['has_next_page'],
      nextOffset: json['next_offset'],
    );
  }
}

class Post {
  final int id;
  final String post;
  final List<Tag> tags;
  final List<Keyword> keywords;
  final String? interactions;
  final String? pollTitle;
  final String? pollDescription;
  final List<Poll> polls;
  final List<Media> media;
  final User user;
  final String privacy;
  final String createdAt;
  final String updatedAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  Post({
    required this.id,
    required this.post,
    required this.tags,
    required this.keywords,
    this.interactions,
    this.pollTitle,
    this.pollDescription,
    required this.polls,
    required this.media,
    required this.user,
    required this.privacy,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      post: json['post'],
      tags: (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList(),
      keywords:
          (json['keywords'] as List).map((kw) => Keyword.fromJson(kw)).toList(),
      interactions: json['interactions'],
      pollTitle: json['poll_title'],
      pollDescription: json['poll_description'],
      polls:
          (json['polls'] as List).map((poll) => Poll.fromJson(poll)).toList(),
      media: (json['media'] as List).map((m) => Media.fromJson(m)).toList(),
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

class Poll {
  final int id;
  final String poll;
  final int voteCount;
  final bool isVoted;

  Poll({
    required this.id,
    required this.poll,
    required this.voteCount,
    required this.isVoted,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      poll: json['poll'],
      voteCount: json['vote_count'],
      isVoted: json['is_voted'],
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
  final String? profileImage;

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
      profileImage: json['profile_image'], // Allowing null here
    );
  }
}
