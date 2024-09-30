import 'userprofile.dart'; 

class FetchResponseModel {
  final UserProfile? follower;
  final UserProfile? following;
  final String? status;
  final DateTime? createdAt;

  FetchResponseModel({
    this.follower,
    this.following,
    this.status,
    this.createdAt,
  });

  factory FetchResponseModel.fromJson(Map<String, dynamic> json) {
    return FetchResponseModel(
      follower: UserProfile.fromJson(json['follower']),
      following: UserProfile.fromJson(json['following']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'follower': follower!.toJson(),
      'following': following!.toJson(),
      'status': status,
      'created_at': createdAt!.toIso8601String(),
    };
  }
}
