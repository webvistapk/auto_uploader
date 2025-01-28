import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/models/follower_following/follower_model.dart';
import 'package:mobile/models/post/tag_people.dart';
import 'package:mobile/prefrences/prefrences.dart';

class ProviderManager {
  static String registrationError = '';
  static Future login(context, String email, String password) async {
    try {
      final completeUrl = Uri.parse(ApiURLs.baseUrl + ApiURLs.login_endpoint);

      final payload = {"username_or_email": email, "password": password};

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        // Add any other necessary headers like Authorization here if required
      };

      log('Complete URL: ${completeUrl.toString()}');
      log('Payload: $payload');
      log('Headers: $headers');

      final response = await http.post(completeUrl,
          body: jsonEncode(payload), headers: headers);
      log('Response Status: ${response.statusCode}');
      log('Response body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        //ToastNotifier.showSuccessToast(context, "Login Successfully");
        return data;
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        final message = data['message'] ?? 'Unauthorized access';
        //ToastNotifier.showErrorToast(context, message);
        return data;
      } else {
        //ToastNotifier.showErrorToast(
        // context, 'Unexpected error: ${response.statusCode}');
        return data;
      }
    } catch (e) {
      log('Error: $e');
      //ToastNotifier.showErrorToast(context, e.toString());
      return null;
    }
  }

  static register(
      context,
      String username,
      String email,
      String firstName,
      String lastName,
      // String phoneNumber,
      String password,
      String dateOfBirth) async {
    try {
      final completeUrl =
          Uri.parse(ApiURLs.baseUrl + ApiURLs.register_endpoint);

      // Payload for registration
      final payload = {
        "username": username,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        // "phone_number": phoneNumber,
        "password": password,
        "birthday": dateOfBirth,
      };

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      log('Complete URL: ${completeUrl.toString()}');
      log('Payload: $payload');
      log('Headers: $headers');

      final response = await http.post(completeUrl,
          body: jsonEncode(payload), headers: headers);
      log('Response Status: ${response.statusCode}');
      log('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        //ToastNotifier.showSuccessToast(context, "Registration Successful");
        return data;
      } else if (response.statusCode == 400) {
        // Show separate error messages for each field
        if (data.containsKey('email')) {
          registrationError = data['email'][0];
          //ToastNotifier.showErrorToast(context, "Email: ${data['email'][0]}");
        }
        if (data.containsKey('phone_number')) {
          registrationError = data['phone_number'][0];
          //ToastNotifier.showErrorToast(
          // context, "Phone Number: ${data['phone_number'][0]}");
        }
        if (data.containsKey('password')) {
          registrationError = data['password'][0];
          log("Error: $registrationError");
          //ToastNotifier.showErrorToast(
          // context, "Password: ${data['password'][0]}");
        }
        if (data.containsKey('username')) {
          registrationError = data['username'][0];
          //ToastNotifier.showErrorToast(
          // context, "Username: ${data['username'][0]}");
        }
        if (data.containsKey('first_name')) {
          registrationError = data['first_name'][0];
          //ToastNotifier.showErrorToast(
          // context, "First Name: ${data['first_name'][0]}");
        }
        if (data.containsKey('last_name')) {
          registrationError = data['last_name'][0];
          //ToastNotifier.showErrorToast(
          // context, "Last Name: ${data['last_name'][0]}");
        }
        return null;
      } else if (response.statusCode == 403) {
        registrationError = data['message'] ?? 'Registration failed';
        //ToastNotifier.showErrorToast(context, message);
        return null;
      } else {
        registrationError = 'Unexpected error: ${response.statusCode}';
        //ToastNotifier.showErrorToast(
        // context, 'Unexpected error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error: $e');
      registrationError = 'Error: $e';
      //ToastNotifier.showErrorToast(context, e.toString());
      return null;
    }
  }

  static Future<bool> checkEmailVerified(context, String email) async {
    final response = await http
        .get(Uri.parse(ApiURLs.baseUrl + ApiURLs.check_email_verified + email));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['verified'];
    }
    return false;
  }

  static Future<String> renewEmailVerified(String email) async {
    try {
      final response = await http.get(
          Uri.parse(ApiURLs.baseUrl + ApiURLs.renew_email_verified + email));
      var data;
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
      }
      return data['status'];
    } catch (e) {
      return e.toString();
    }
  }

  static updateEmailVerified(String email, String verificationCode) async {
    try {
      final response = await http.patch(
        Uri.parse(ApiURLs.baseUrl + ApiURLs.update_email_verified + email),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email_verification_code': verificationCode}),
      );
      var data;
      // debugger();
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 400) {
        data = jsonDecode(response.body);
        return data;
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

////Phone Verification

  static checkPhoneVerified(context, String email) async {
    final response = await http
        .get(Uri.parse(ApiURLs.baseUrl + ApiURLs.check_phone_verified + email));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    }
    return null;
  }

  static Future<String> renewPhoneVerified(String email) async {
    try {
      final response = await http.get(
          Uri.parse(ApiURLs.baseUrl + ApiURLs.renew_phone_verified + email));
      var data;
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
      }
      return data['status'];
    } catch (e) {
      return e.toString();
    }
  }

  static updatePhoneVerified(String email, String verificationCode) async {
    try {
      final response = await http.patch(
        Uri.parse(ApiURLs.baseUrl + ApiURLs.update_phone_verified + email),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone_verification_code': verificationCode}),
      );
      var data;
      // debugger();
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 400) {
        data = jsonDecode(response.body);
        return data;
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static updatePhoneNumber(
    int userId,
    String phoneNumber,
  ) async {
    final String? token = await Prefrences.getAuthToken();
    // Define the API endpoint
    final url =
        Uri.parse('${ApiURLs.baseUrl}${ApiURLs.update_phone_number}$userId');

    // Define the headers

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // Define the request body
    final body = jsonEncode({
      'phone_number': phoneNumber,
    });

    try {
      // Make the PUT request
      final response = await http.put(
        url,
        headers: headers,
        body: body,
      );
      final data = jsonDecode(response.body);
      // Check the response
      // debugger();
      if (response.statusCode == 200) {
        log('Phone number updated successfully.');

        return data;
      } else {
        log('Failed to update phone number. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  static Future<UserProfile> fetchUserProfile(int id) async {
    final String? token = await Prefrences.getAuthToken();

    final response = await http.get(
      Uri.parse('${ApiURLs.baseUrl}${ApiURLs.user_endpoint}$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    // debugger();
    if (response.statusCode == 200) {
      log(response.body);
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  static updateUserProfile(UserProfile userProfile) async {
    final String? token = await Prefrences.getAuthToken();
    int currentUserId = JwtDecoder.decode(token.toString())['user_id'];

    // Ensure the user can only update their own profile
    if (currentUserId != userProfile.id) {
      throw Exception('You can only edit your own profile.');
    }

    final url =
        '${ApiURLs.baseUrl}${ApiURLs.update_user_profile}${userProfile.id}/';
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Any thing Else please try Again!");
    }
  }

  static createNewPost(token,
      {required String postTitle,
      required List<int> peopleTags,
      required List<String> keywordsList,
      required String privacyPost,
      required List<File> mediaFiles}) async {
    try {
      final completeUrl = Uri.parse(ApiURLs.baseUrl + ApiURLs.create_new_post);
      final body = {};
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-type': 'application/json'
      };

      final response =
          await http.post(completeUrl, headers: headers, body: body);
      if (response.statusCode == 200) {
      } else {}
    } catch (e) {}
  }

  static Future<List<TagUser>> fetchFollowersAndFollowings(
      String token, int id) async {
    final String url = '${ApiURLs.baseUrl}userprofile/users/follow/getall/$id/';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    // debugger();
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log(response.body);
      return combineFollowersAndFollowings(responseData);
    } else {
      return [];
    }
  }

  static List<TagUser> combineFollowersAndFollowings(
      Map<String, dynamic> response) {
    List<TagUser> combinedList = [];

    // Parse followers
    if (response['followers'] != null) {
      for (var follower in response['followers']) {
        combinedList.add(TagUser.fromJson(follower));
      }
    }

    // Parse followings
    if (response['followings'] != null) {
      for (var following in response['followings']) {
        combinedList.add(TagUser.fromJson(following));
      }
    }

    return combinedList;
  }

  // _________________ Followers Data ___________________/////////////
  static fetchFollowers(String authToken, int userID) async {
    String token = authToken;
    final String url =
        "${ApiURLs.baseUrl}${ApiURLs.fetch_peoples_endpoint}$userID/";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> followersData = data["followers"] ?? [];
        final followers = followersData
            .map((followerJson) => Follower.fromJson(followerJson))
            .toList();
        log("Followers: $followersData");
        await Prefrences.saveFollowers(followersData);
        return followers;
      } else {
        print("Failed to load followers");
        throw Exception("Failed to load followers");
      }
    } catch (error) {
      print("Error fetching followers: $error");
      throw Exception("Error fetching followers: $error");
    }
  }
}
