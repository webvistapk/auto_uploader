import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userstatus.dart';
import '../../prefrences/prefrences.dart';
import '../endpoints.dart';
import 'package:http/http.dart' as http; // Import http package

class MediaProvider with ChangeNotifier {
  Userstatus? _userStatus;
  Userstatus? _followersStatus;

  // Getters for user and followers' stories
  Userstatus? get userStatus => _userStatus;
  Userstatus? get followersStatus => _followersStatus;

  // Method to fetch and update user status internally
  void fetchUserStatus(Userstatus userStatus) {
    _userStatus = userStatus;
    notifyListeners();
  }

  // Method to fetch and update followers' stories internally
  void fetchFollowersStatus(Userstatus followersStatus) {
    _followersStatus = followersStatus;
    notifyListeners();
  }
}

class StoryService {
  final MediaProvider mediaProvider;

  StoryService(this.mediaProvider);

  Future<void> getUserStatus() async {
    final String? token = await Prefrences.getAuthToken();
    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    final String url = '${ApiURLs.baseUrl}${ApiURLs.get_user_status}$_loggedInUserId';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final userStatus = Userstatus.fromJson(data);
          mediaProvider.fetchUserStatus(userStatus);
        } else {
          print("Failed to fetch user stories: ${data['message']}");
        }
      } else {
        print("Failed to fetch user stories with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  // Method to fetch followers' stories
  Future<void> getFollowersStatus() async {
    final String? token = await Prefrences.getAuthToken();
    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    final String url = '${ApiURLs.baseUrl}${ApiURLs.get_followers_status}$_loggedInUserId';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          print("Successfully");
          final followersStatus = Userstatus.fromJson(data);
          mediaProvider.fetchFollowersStatus(followersStatus);
        } else {
          print("Failed to fetch followers' stories: ${data['message']}");
        }
      } else {
        print("Failed to fetch followers' stories with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }
}


