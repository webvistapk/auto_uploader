// import 'dart:convert';
// import 'package:mobile/models/UserProfile/userprofile.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Update the path based on your file structure

// class UserPreferences {
//   static const String userKey = 'user_list';

//   // Save a list of UserProfiles to SharedPreferences
//   Future<void> saveUserList(List<UserProfile> users) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Convert each UserProfile to JSON and store in a list
//     List<String> jsonStringList =
//         users.map((user) => jsonEncode(user.toJson())).toList();

//     // Store the JSON string list in SharedPreferences
//     await prefs.setStringList(userKey, jsonStringList);
//   }

//   // Get a list of UserProfiles from SharedPreferences
//   Future<List<UserProfile>> getUserList() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Retrieve the JSON string list from SharedPreferences
//     List<String>? jsonStringList = prefs.getStringList(userKey);

//     // Convert the JSON string list back to a list of UserProfiles
//     if (jsonStringList != null) {
//       return jsonStringList
//           .map((jsonString) => UserProfile.fromJson(jsonDecode(jsonString)))
//           .toList();
//     }

//     // Return an empty list if nothing is found
//     return [];
//   }

//   // Remove all saved users
//   Future<void> clearUserList() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(userKey);
//   }
// }
import 'dart:convert';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String userKey = 'current_user';

  // Save current UserProfile to SharedPreferences
  Future<void> saveCurrentUser(UserProfile user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert UserProfile to JSON string
    String jsonString = jsonEncode(user.toJson());

    // Store the JSON string in SharedPreferences
    await prefs.setString(userKey, jsonString);
  }

  // Get the current UserProfile from SharedPreferences
   getCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string from SharedPreferences
    String? jsonString = prefs.getString(userKey);

    // Convert the JSON string back to a UserProfile
    if (jsonString != null) {
      return UserProfile.fromJson(jsonDecode(jsonString));
    }

    // Return null if no user is found
    return null;
  }

  // Remove the current user from SharedPreferences
  Future<void> clearCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
  }
}
