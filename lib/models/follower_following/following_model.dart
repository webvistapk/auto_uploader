class Following {
  final int? id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final bool? isFollowing;
  final String? profileImage; // New profile image variable

  Following({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.isFollowing,
    this.profileImage,
  });

  // Factory method to create a Following object from JSON
  factory Following.fromJson(Map<String, dynamic> json) {
    return Following(
      id: json['id'] as int?,
      username: json['username'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      isFollowing: json['isFollowing'] as bool?,
      profileImage: json['profile_image'] as String? ?? '', // Handle null
    );
  }

  // Convert Following object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'isFollowing': isFollowing,
      'profile_image': profileImage ?? '', // Handle null
    };
  }
}
