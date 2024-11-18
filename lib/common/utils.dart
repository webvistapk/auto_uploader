import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  // static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const bool devMode = true;

  static const String privacy_private = "private";
  static const String privacy_public = "public";
  static const String privacy_followers = "followers";
  static const String follower_accepted = "accepted";
  // static const String authToken = "auth_token";
  static const String testImage =
      "https://static.printler.com/cache/3/a/0/6/1/4/3a0614c4a9deb4f62bf47766860f4ca526debe02.jpg";
  static const String userImage =
      "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y";

  static Future<void> storeAuthToken(String key, String value) async {
    if (kIsWeb) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      // await _secureStorage.write(key: key, value: value);
    }
  }

  static Future<String?> getAuthToken(String key) async {
    if (kIsWeb) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      // return await _secureStorage.read(key: key);
    }
  }

  static void launchUrl(String url) async {
    if (await canLaunchUrl(url as Uri)) {
      launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
