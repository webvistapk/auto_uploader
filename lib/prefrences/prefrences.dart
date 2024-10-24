import 'package:shared_preferences/shared_preferences.dart';

class Prefrences {
  static const String authToken = "authToken";
  static const String refreshKey = "refreshToken";
  static const String userEmail = "userEmail";
  static const String mediaPermission = "mediaPermission";
  static const String userID = "id";

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
}
