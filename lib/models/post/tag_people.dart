class TagUser {
  final int id;
  final String username;
  final String firstName;
  final String lastName;

  TagUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory TagUser.fromJson(Map<String, dynamic> json) {
    return TagUser(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  @override
  String toString() {
    return '$firstName $lastName';
  }
}
