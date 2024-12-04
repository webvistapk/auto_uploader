class TagUser {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profileImage;

  TagUser(
      {required this.id,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.profileImage});

  factory TagUser.fromJson(Map<String, dynamic> json) {
    return TagUser(
        id: json['id'],
        username: json['username'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        profileImage: json['profile_image']);
  }

  @override
  String toString() {
    return '$firstName $lastName';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
