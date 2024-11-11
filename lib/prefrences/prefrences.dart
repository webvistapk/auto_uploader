import 'dart:convert';

import 'package:mobile/models/follower_following/follower_model.dart';
import 'package:mobile/models/follower_following/following_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefrences {
  static const String authToken = "authToken";
  static const String refreshKey = "refreshToken";
  static const String userEmail = "userEmail";
  static const String mediaPermission = "mediaPermission";
  static const String userID = "id";
  static const String followerKey = 'followers';
  static const String followingKey = 'followings';
  static const String statusPermissionKey = "statusKey";

  static SetAuthToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(authToken, accessToken);
  }

  static getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(authToken);
  }

  static getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userID);
  }

  static SetUserId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(userID, id);
  }

  static SetUserEmail(String user_email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userEmail, user_email);
  }

  static Future<String?> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmail);
  }

  static removeAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(Prefrences.authToken);
  }

  static setMediaPermission(bool permission) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(mediaPermission, permission);
  }

  static getMediaPermission() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(mediaPermission) ?? false;
  }

  static setStoryPermission(bool permission) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(statusPermissionKey, permission);
  }

  static getStoryPermission() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(statusPermissionKey) ?? false;
  }

  static Future<void> saveFollowers(List<dynamic> followersData) async {
    final List<Follower> followers = followersData
        .map((followerJson) => Follower.fromJson(followerJson))
        .toList();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefrences.followerKey,
        json.encode(followers.map((f) => f.toJson()).toList()));
  }

  static Future<void> saveFollowings(List<dynamic> followingsData) async {
    final List<Following> followings = followingsData
        .map((followingJson) => Following.fromJson(followingJson))
        .toList();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefrences.followingKey,
        json.encode(followings.map((f) => f.toJson()).toList()));
  }

  static Future<List<Follower>> getFollowers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? followersString = prefs.getString(Prefrences.followerKey);

    if (followersString != null) {
      List<dynamic> followersJson = json.decode(followersString);
      return followersJson.map((json) => Follower.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Following>> getFollowings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? followingsString = prefs.getString(Prefrences.followingKey);

    if (followingsString != null) {
      List<dynamic> followingsJson = json.decode(followingsString);
      return followingsJson.map((json) => Following.fromJson(json)).toList();
    }
    return [];
  }
}
