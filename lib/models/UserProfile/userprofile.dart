import 'package:mobile/models/UserProfile/roles.dart';

class UserProfile {
  final int id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? description;
  final String? position;
  final String? organization;
  final String? address;
  final String? city;
  final String? country;
  final String? website;
  final int? followers_count;
  final int? following_count;
  final String? privacy;
  final Roles? roles;

  UserProfile({
    required this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.description,
    this.position,
    this.organization,
    this.address,
    this.city,
    this.country,
    this.website,
    this.followers_count,
    this.following_count,
    this.privacy,
    this.roles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      description: json['description'],
      position: json['position'],
      organization: json['organization'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      website: json['website'],
      followers_count: json['followers_count'],
      following_count: json['following_count'],
      privacy: json['privacy'],
      roles: json['roles'] != null ? Roles.fromJson(json['roles']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'description': description,
      'position': position,
      'organization': organization,
      'address': address,
      'city': city,
      'country': country,
      'website': website,
      'followers_count': followers_count,
      'following_count': following_count,
      'privacy': privacy,
      'roles': roles?.toJson(), // Assuming Roles class also has a toJson method
    };
  }

}
