class Roles {
  final String name;

  Roles({required this.name});

  factory Roles.fromJson(Map<String, dynamic> json) {
    return Roles(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
