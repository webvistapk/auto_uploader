class TagPost {
  final int id;
  final String username;
  final String firstName;
  final String lastName;

  TagPost({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory TagPost.fromJson(Map<String, dynamic> json) {
    return TagPost(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}
