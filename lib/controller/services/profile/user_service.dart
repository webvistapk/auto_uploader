import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/models/UserProfile/followers.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';

class UserService {
  static Future<UserProfile> fetchUserProfile(int id) async {
    final String? token = await AppUtils.getAuthToken(AppUtils.authToken);

    final response = await http.get(
      Uri.parse('${ApiURLs.baseUrl}${ApiURLs.user_endpoint}$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  static Future<void> updateUserProfile(UserProfile userProfile) async {
    final String? token = await AppUtils.getAuthToken(AppUtils.authToken);
    int currentUserId = JwtDecoder.decode(token.toString())['user_id'];

    // Ensure the user can only update their own profile
    if (currentUserId != userProfile.id) {
      throw Exception('You can only edit your own profile.');
    }

    final url = '${ApiURLs.baseUrl}${userProfile.id}/';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': userProfile.email,
        'first_name': userProfile.firstName,
        'last_name': userProfile.lastName,
        'phone_number': userProfile.phoneNumber,
        'description': userProfile.description,
        'position': userProfile.position,
        'organization': userProfile.organization,
        'address': userProfile.address,
        'city': userProfile.city,
        'country': userProfile.country,
        'website': userProfile.website,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user profile: ${response.body}');
    }
  }

  static Future<String> registerUser({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    const url = '${ApiURLs.baseUrl}${ApiURLs.register_endpoint}';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['access']; // Return the access token
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final String? token = await AppUtils.getAuthToken(AppUtils.authToken);
    int userId = JwtDecoder.decode(token.toString())['user_id'];

    final response = await http.put(
      Uri.parse('${ApiURLs.baseUrl}${ApiURLs.follow_request_endpoint}$userId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to change password: ${response.body}');
    }
  }

  static Future<FetchResponseModel> followRequest(
      int followerId, int followingId) async {
    final String? token = await AppUtils.getAuthToken(AppUtils.authToken);
    final response = await http.post(
      Uri.parse(
          "${ApiURLs.baseUrl}${ApiURLs.follow_request_endpoint}$followingId/$followerId/"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data=response.body;
      return FetchResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to Send follow request status ${response.statusCode}');
    }
  }

  static Future<FetchResponseModel> fetchFollowRequestStatus(
      int followerId, int followingId) async {
    final String? token = await AppUtils.getAuthToken(AppUtils.authToken);

    final response = await http.get(
      Uri.parse(
          '${ApiURLs.baseUrl}${ApiURLs.follow_request_endpoint}$followerId/$followingId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return FetchResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load follow request status');
    }
  }
}
