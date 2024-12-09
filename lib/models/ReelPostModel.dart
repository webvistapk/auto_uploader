import 'dart:convert';

class ReelPostModel {
  final int id;
  final String file;
  final List<String> tags;
  final List<Keyword> keywords;
  final User user;
  final DateTime createdAt;
  final DateTime updatedAt;
   int likesCount;
   int commentsCount;
   bool isLiked;

  ReelPostModel({
    required this.id,
    required this.file,
    required this.tags,
    required this.keywords,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked
  });

  factory ReelPostModel.fromJson(Map<String, dynamic> json) {
    return ReelPostModel(
      id: json['id'] ?? 0, // Default value if null
      file: json['file'] ?? '', // Default value if null
      tags: List<String>.from(json['tags'] ?? []), // Empty list if null
      keywords: (json['keywords'] as List?)
              ?.map((keywordJson) => Keyword.fromJson(keywordJson))
              .toList() ??
          [], // Empty list if null
      user: User.fromJson(json['user'] ?? {}), // Handle user field
      createdAt: DateTime.parse(json['created_at'] ??
          DateTime.now().toIso8601String()), // Default to now if null
      updatedAt: DateTime.parse(json['updated_at'] ??
          DateTime.now().toIso8601String()), // Default to now if null
      likesCount: json['likes_count'] ?? 0, // Default value if null
      commentsCount: json['comments_count'] ?? 0, // Default value if null
      isLiked: json['is_liked']??false,
    );
  }
}

class Reel {
  final int id;
  final String file;
  final List<String> tags;
  final List<Keyword> keywords;
  final User user;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  Reel({
    required this.id,
    required this.file,
    required this.tags,
    required this.keywords,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked
  });

  // Factory constructor to parse JSON data
  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'],
      file: json['file'],
      tags: List<String>.from(json['tags']),
      keywords: (json['keywords'] as List)
          .map((keywordJson) => Keyword.fromJson(keywordJson))
          .toList(),
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      isLiked: json['is_liked']
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

  // Factory constructor to parse JSON data
  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      id: json['id'],
      word: json['word'],
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

  // Factory constructor to parse JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}
