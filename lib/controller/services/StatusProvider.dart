import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/followerStoriesModel.dart';
import 'package:mobile/models/UserProfile/userstatus.dart';
import '../../prefrences/prefrences.dart';
import '../endpoints.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:mobile/models/UserProfile/followerStoriesModel.dart' as followerStoriesModel;
import 'package:mobile/models/UserProfile/userstatus.dart' as userStatusModel;

class MediaProvider with ChangeNotifier {

  bool _isLoading = false;
  bool _hasMore = true;
  int _nextOffset = 0;  // Keep track of the next offset for pagination
  List<Stories> _statuses = [];
  int _offset=0;  // List to store fetched statuses

  List<Stories> get statuses => _statuses;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get nextOffset=>_nextOffset;
  int get offset=>_offset;
   Userstatus? _followersStatus;
  Userstatus? get followersStatus => _followersStatus;
   final List<Stories> _stories = [];
  bool _hasNextPage = true;
  List<Stories> get stories => _stories;
  
  setisLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  // Method to fetch user statuses with pagination
  Future<void> fetchUserStatuses({int limit = 10, int offset = 0}) async {
    final String? token = await Prefrences.getAuthToken();
    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    final String url = '${ApiURLs.baseUrl}${ApiURLs.get_user_status}$_loggedInUserId';
    
    try {
      final response = await http.get(Uri.parse(url).replace(queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      }), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          Userstatus statusResponse = Userstatus.fromJson(data);
          
          // If offset is 0, clear the existing statuses and load new ones
          if (offset == 0) {
            _statuses = statusResponse.stories!;  // Clear and load new statuses
            _nextOffset = statusResponse.nextOffset ?? 0;  // Update nextOffset
          } else {
            _statuses.addAll(statusResponse.stories!);  // Append new statuses
            _nextOffset = statusResponse.nextOffset ?? _nextOffset;
          }

          // If there are no more statuses, set nextOffset to -1
          if (!statusResponse.hasNextPage!) {
            _hasMore = false;
            _nextOffset = -1;
          }

          notifyListeners();  // Notify listeners to update the UI
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
  
 
  Future<void> fetchFollowerStories(BuildContext context,{int limit=4,offset=0}) async {
  // Prevent duplicate calls if already loading or no more pages
  if (_isLoading || !_hasNextPage) return;

  _isLoading = true;
  notifyListeners();

  try {
    final String? token = await Prefrences.getAuthToken();
    int? loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    String URL =
        "${ApiURLs.baseUrl}${ApiURLs.get_followers_status}$loggedInUserId/";

    Uri uri = Uri.parse(URL).replace(queryParameters: {
      'limit': limit.toString(),
      'offset': _offset.toString(),
    });

    final response = await http.get(uri, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
//debugger();
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      FollowerStoriesModel followerResponse = FollowerStoriesModel.fromJson(data);

       for (var user in followerResponse.users) {
        // Check if the user is already in the list
        if (!_stories.any((story) => story.user!.id == user.id)) {
          _stories.add(userStatusModel.Stories(
            id: user.id,
            tags: [],
            media: user.stories.expand((story) => story.media ?? []).map((media) => userStatusModel.Media(
              id: media.id,
              mediaType: media.mediaType,
              file: media.file,
            )).toList(),
            privacy: "",
            createdAt: "",
            updatedAt: "",
            seenCount: 0,
            user: userStatusModel.User(
              id: user.id,
              username: user.username,
              profileImage: user.profileImage,
            ),
          ));
        }
      }

      _offset += limit; // Increment offset for next fetch
      _hasNextPage = followerResponse.hasNextPage; // Update pagination state
    } else {
      throw Exception("Failed to fetch follower stories");
    }
  } catch (e) {
    ToastNotifier.showErrorToast(context, "Error: $e");
    print("Error fetching follower stories: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

deleteUserStories(int storyId,BuildContext context)async{
   final String? token = await Prefrences.getAuthToken();
    //print("Reel ID ${postID}");
    String URL = "${ApiURLs.baseUrl}${ApiURLs.delete_user_status}$storyId/";

    // print("Post ID in Like ${postID}");

    try {
      final response = await http.delete(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      //debugger();
      print("API HITTED");
      if (response.statusCode == 200) {
        // _reels?[reelIndex].isLiked = true;
   // ToastNotifier.showErrorToast(context, "Story Deleted");
        // Notify listeners to update UI
        notifyListeners();
      } 
    } catch (e) {
      //ToastNotifier.showErrorToast(context, "Error disliking the post: $e");
      print(e);
    }
}

}

