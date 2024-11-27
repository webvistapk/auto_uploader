class Userstatus {
  Userstatus({
    String? status,
    List<Stories>? stories,
    num? totalCount,
    bool? hasNextPage,
    dynamic nextOffset,
  }) {
    _status = status;
    _stories = stories;
    _totalCount = totalCount;
    _hasNextPage = hasNextPage;
    _nextOffset = nextOffset;
  }

  Userstatus.fromJson(dynamic json) {
    _status = json['status'];
    if (json['stories'] != null) {
      _stories = [];
      json['stories'].forEach((v) {
        _stories?.add(Stories.fromJson(v));
      });
    }
    _totalCount = json['total_count'];
    _hasNextPage = json['has_next_page'];
    _nextOffset = json['next_offset'];
  }

  String? _status;
  List<Stories>? _stories;
  num? _totalCount;
  bool? _hasNextPage;
  dynamic _nextOffset;

  Userstatus copyWith({
    String? status,
    List<Stories>? stories,
    num? totalCount,
    bool? hasNextPage,
    dynamic nextOffset,
  }) =>
      Userstatus(
        status: status ?? _status,
        stories: stories ?? _stories,
        totalCount: totalCount ?? _totalCount,
        hasNextPage: hasNextPage ?? _hasNextPage,
        nextOffset: nextOffset ?? _nextOffset,
      );

  String? get status => _status;
  List<Stories>? get stories => _stories;
  num? get totalCount => _totalCount;
  bool? get hasNextPage => _hasNextPage;
  dynamic get nextOffset => _nextOffset;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_stories != null) {
      map['stories'] = _stories?.map((v) => v.toJson()).toList();
    }
    map['total_count'] = _totalCount;
    map['has_next_page'] = _hasNextPage;
    map['next_offset'] = _nextOffset;
    return map;
  }
}

class Stories {
  Stories({
    num? id,
    List<dynamic>? tags,
    List<Media>? media,
    User? user,
    String? privacy,
    String? createdAt,
    String? updatedAt,
    num? seenCount,
  }) {
    _id = id;
    _tags = tags;
    _media = media;
    _user = user;
    _privacy = privacy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _seenCount = seenCount;
  }

  Stories.fromJson(dynamic json) {
    _id = json['id'];
    _tags = json['tags'] ?? [];
    if (json['media'] != null) {
      _media = [];
      json['media'].forEach((v) {
        _media?.add(Media.fromJson(v));
      });
    }
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _privacy = json['privacy'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _seenCount = json['seen_count'];
  }

  num? _id;
  List<dynamic>? _tags;
  List<Media>? _media;
  User? _user;
  String? _privacy;
  String? _createdAt;
  String? _updatedAt;
  num? _seenCount;

  Stories copyWith({
    num? id,
    List<dynamic>? tags,
    List<Media>? media,
    User? user,
    String? privacy,
    String? createdAt,
    String? updatedAt,
    num? seenCount,
  }) =>
      Stories(
        id: id ?? _id,
        tags: tags ?? _tags,
        media: media ?? _media,
        user: user ?? _user,
        privacy: privacy ?? _privacy,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        seenCount: seenCount ?? _seenCount,
      );

  num? get id => _id;
  List<dynamic>? get tags => _tags;
  List<Media>? get media => _media;
  User? get user => _user;
  String? get privacy => _privacy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get seenCount => _seenCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['tags'] = _tags;
    if (_media != null) {
      map['media'] = _media?.map((v) => v.toJson()).toList();
    }
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    map['privacy'] = _privacy;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['seen_count'] = _seenCount;
    return map;
  }
}

class User {
  User({
    num? id,
    String? username,
    String? firstName,
    String? lastName,
    String? profileImage,
  }) {
    _id = id;
    _username = username;
    _firstName = firstName;
    _lastName = lastName;
    _profileImage = profileImage;
  }

  User.fromJson(dynamic json) {
    _id = json['id'];
    _username = json['username'];
    _firstName = json['first_name'];
    _lastName = json['last_name'];
    _profileImage = json['profile_image'];
  }

  num? _id;
  String? _username;
  String? _firstName;
  String? _lastName;
  String? _profileImage;

  User copyWith({
    num? id,
    String? username,
    String? firstName,
    String? lastName,
    String? profileImage,
  }) =>
      User(
        id: id ?? _id,
        username: username ?? _username,
        firstName: firstName ?? _firstName,
        lastName: lastName ?? _lastName,
        profileImage: profileImage ?? _profileImage,
      );

  num? get id => _id;
  String? get username => _username;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get profileImage => _profileImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['username'] = _username;
    map['first_name'] = _firstName;
    map['last_name'] = _lastName;
    map['profile_image'] = _profileImage;
    return map;
  }
}

class Media {
  Media({
    num? id,
    String? mediaType,
    String? file,
  }) {
    _id = id;
    _mediaType = mediaType;
    _file = file;
  }

  Media.fromJson(dynamic json) {
    _id = json['id'];
    _mediaType = json['media_type'];
    _file = json['file'];
  }

  num? _id;
  String? _mediaType;
  String? _file;

  Media copyWith({
    num? id,
    String? mediaType,
    String? file,
  }) =>
      Media(
        id: id ?? _id,
        mediaType: mediaType ?? _mediaType,
        file: file ?? _file,
      );

  num? get id => _id;
  String? get mediaType => _mediaType;
  String? get file => _file;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['media_type'] = _mediaType;
    map['file'] = _file;
    return map;
  }
}
