import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/common/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> isAuthenticated() async {
    String? token = await Utils.getAuthToken(Utils.authToken);

    // You can add additional token validation logic here if needed
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    if (kIsWeb) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(Utils.authToken);
    } else {
      const FlutterSecureStorage secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: Utils.authToken);
    }
  }
}
