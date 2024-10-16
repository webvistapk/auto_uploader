import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';

class ProviderManager {
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
        ToastNotifier.showSuccessToast(context, "Login Successfully");
        return data;
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        final message = data['message'] ?? 'Unauthorized access';
        ToastNotifier.showErrorToast(context, message);
        return null;
      } else {
        ToastNotifier.showErrorToast(
            context, 'Unexpected error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error: $e');
      ToastNotifier.showErrorToast(context, e.toString());
      return null;
    }
  }

  static register(context, String username, String email, String firstName,
      String lastName, String phoneNumber, String password) async {
    try {
      final completeUrl =
          Uri.parse(ApiURLs.baseUrl + ApiURLs.register_endpoint);

      // Payload for registration
      final payload = {
        "username": username,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "phone_number": phoneNumber,
        "password": password,
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
        ToastNotifier.showSuccessToast(context, "Registration Successful");
        return data;
      } else if (response.statusCode == 400) {
        // Show separate error messages for each field
        if (data.containsKey('email')) {
          ToastNotifier.showErrorToast(context, "Email: ${data['email'][0]}");
        }
        if (data.containsKey('phone_number')) {
          ToastNotifier.showErrorToast(
              context, "Phone Number: ${data['phone_number'][0]}");
        }
        if (data.containsKey('password')) {
          ToastNotifier.showErrorToast(
              context, "Password: ${data['password'][0]}");
        }
        if (data.containsKey('username')) {
          ToastNotifier.showErrorToast(
              context, "Username: ${data['username'][0]}");
        }
        if (data.containsKey('first_name')) {
          ToastNotifier.showErrorToast(
              context, "First Name: ${data['first_name'][0]}");
        }
        if (data.containsKey('last_name')) {
          ToastNotifier.showErrorToast(
              context, "Last Name: ${data['last_name'][0]}");
        }
        return null;
      } else if (response.statusCode == 403) {
        final message = data['message'] ?? 'Registration failed';
        ToastNotifier.showErrorToast(context, message);
        return null;
      } else {
        ToastNotifier.showErrorToast(
            context, 'Unexpected error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error: $e');
      ToastNotifier.showErrorToast(context, e.toString());
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

  createNewPost(token,
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
}
