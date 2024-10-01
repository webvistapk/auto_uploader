class FollowerRequestModel {
  FollowerRequestModel({
    this.follower,
    this.following,
    this.status,
    this.createdAt,
  });

  final User? follower;
  final User? following;
  final String? status;
  final DateTime? createdAt;

  // Factory method to create from JSON
  factory FollowerRequestModel.fromJson(Map<String, dynamic> json) {
    return FollowerRequestModel(
      follower: User.fromJson(json['follower']),
      following: User.fromJson(json['following']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['follower'] = follower?.toJson();
    data['following'] = following?.toJson();
    data['status'] = status;
    data['created_at'] = createdAt?.toIso8601String();
    return data;
  }
}

class User {
  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;

  // Factory method to create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    return data;
  }
}
