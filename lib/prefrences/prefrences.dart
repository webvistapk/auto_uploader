import 'package:shared_preferences/shared_preferences.dart';

class Prefrences {
  static const String authToken = "authToken";
  static const String refreshKey = "refreshToken";

  static SetAuthToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(authToken, accessToken);
  }
}
