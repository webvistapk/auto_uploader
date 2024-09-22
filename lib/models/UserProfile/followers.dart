import 'userprofile.dart'; 

class FollowRequest {
  final UserProfile follower;
  final UserProfile following;
  final String status;
  final DateTime createdAt;

  FollowRequest({
    required this.follower,
    required this.following,
    required this.status,
    required this.createdAt,
  });

  factory FollowRequest.fromJson(Map<String, dynamic> json) {
    return FollowRequest(
      follower: UserProfile.fromJson(json['follower']),
      following: UserProfile.fromJson(json['following']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'follower': follower.toJson(),
      'following': following.toJson(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
