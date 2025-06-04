class PostResponse {
  final String? totalcount;
  final bool? has_next_page;
  final int? next_offset;
  List<PostModel>? postModel;

  PostResponse(
      {this.totalcount, this.has_next_page, this.next_offset, this.postModel});

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      totalcount: json["total_count"] ?? '',
      has_next_page: json['has_next_page'] ?? false,
      next_offset: json['next_offset'] ?? 0,
      postModel: (json['posts'] as List)
          .map((item) => PostModel.fromJson(item))
          .toList(),
    );
  }
}

// "is_reposted": false,
//             "reposted_by": null,
class PostModel {
  final int id;
  final String post;
  final List<Tag> tags;
  final List<Keyword> keywords;
  final String? interactions;
  final String? pollTitle;
  final String? pollDescription;
  final List<Poll>? polls; // Optional list of polls
  final List<Media> media;
  final User user;
  final List<String> privacy;
  final String createdAt;
  final String updatedAt;
  int likesCount;
  int commentsCount;
  bool isLiked;
  final String? postTitle;
  final String? postDescription;
  final String? location;
  final bool? isReposted;
  final User? repostedBy;
  final int? repostCount;
  final bool? showDm;
  final bool? showComment;

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
    required this.isLiked,
    this.interactions,
    this.pollTitle,
    this.pollDescription,
    this.polls, // Optional list of polls
    this.postTitle,
    this.postDescription,
    this.location,
    this.isReposted,
    this.repostedBy,
    this.repostCount,
    required this.showDm,
    required this.showComment,
  });

  // Factory method to parse JSON data
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        id: json['id'],
        post: json['post'],
        tags: (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList(),
        keywords: (json['keywords'] as List)
            .map((kw) => Keyword.fromJson(kw))
            .toList(),
        interactions: json['interactions'],
        pollTitle: json['poll_title'],
        pollDescription: json['poll_description'],
        polls: (json['polls'] as List?)
            ?.map((poll) => Poll.fromJson(poll))
            .toList(), // Parse polls list if available
        media: (json['media'] as List).map((m) => Media.fromJson(m)).toList(),
        user: User.fromJson(json['user']),
        privacy: List<String>.from(json['privacy']),
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        likesCount: json['likes_count'],
        commentsCount: json['comments_count'],
        isLiked: json['is_liked'] ?? false,
        postTitle: json['post_title'],
        postDescription: json['post_description'],
        location: json['location'] ?? "",
        isReposted: json['is_reposted'] ?? false,
        repostedBy: json['reposted_by'] == null
            ? null
            : User.fromJson(json['reposted_by']),
        repostCount: json['repost_count'],
        showDm: json['show_dm'] ?? false,
        showComment: json['show_comment'] ?? false);
  }
  static Map<String, dynamic> postModelToJson(PostModel post) {
    return {
      'id': post.id,
      'post': post.post,
      'tags': post.tags
          .map((tag) => {
                'id': tag.id,
                'username': tag.username,
                'first_name': tag.firstName,
                'last_name': tag.lastName,
              })
          .toList(),
      'keywords': post.keywords
          .map((kw) => {
                'id': kw.id,
                'word': kw.word,
              })
          .toList(),
      'interactions': post.interactions,
      'poll_title': post.pollTitle,
      'poll_description': post.pollDescription,
      'polls': post.polls
          ?.map((poll) => {
                'id': poll.id,
                'poll': poll.poll,
                'vote_count': poll.voteCount,
                'is_voted': poll.isVoted,
              })
          .toList(),
      'media': post.media
          .map((m) => {
                'id': m.id,
                'media_type': m.mediaType,
                'file': m.file,
              })
          .toList(),
      'user': {
        'id': post.user.id,
        'username': post.user.username,
        'first_name': post.user.firstName,
        'last_name': post.user.lastName,
        'profile_image': post.user.profileImage ?? '',
      },
      'privacy': post.privacy,
      'created_at': post.createdAt,
      'updated_at': post.updatedAt,
      'likes_count': post.likesCount,
      'comments_count': post.commentsCount,
      'is_liked': post.isLiked ?? false,
      'post_title': post.postTitle,
      'post_description': post.postDescription,
      'location': post.location,
      'is_reposted': post.isReposted,
      'reposted_by': post.repostedBy != null
          ? {
              'id': post.repostedBy!.id,
              'username': post.repostedBy!.username,
              'first_name': post.repostedBy!.firstName,
              'last_name': post.repostedBy!.lastName,
              'profile_image': post.repostedBy!.profileImage ?? '',
            }
          : null,
      'repost_count': post.repostCount,
      'show_dm': post.showDm,
      'show_comment': post.showComment
    };
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
  int calculateTotalVotes(List<Poll> polls) {
    return polls.fold(0, (sum, poll) => sum + poll.voteCount);
  }

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      poll: json['poll'],
      voteCount: json['vote_count'],
      isVoted: json['is_voted'],
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
      profileImage: json['profile_image'] ?? '', // Parse the profileImage field
    );
  }
}
