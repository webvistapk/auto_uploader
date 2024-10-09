import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/update%20password/widget/custom_widget.dart';
import 'package:mobile/screens/profile/mainscreen/main_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';

import '../../../controller/endpoints.dart';
import '../../../prefrences/prefrences.dart';

class ConfirmPasswordScreen extends StatefulWidget {
  final String oldPassword;
  final String newPassword;

  ConfirmPasswordScreen({required this.oldPassword, required this.newPassword});

  @override
  _ConfirmPasswordScreenState createState() => _ConfirmPasswordScreenState();
}

class _ConfirmPasswordScreenState extends State<ConfirmPasswordScreen> {
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> updatePassword(
      BuildContext context, String oldPassword, String newPassword) async {
    try {
      final String? token = await Prefrences.getAuthToken();
      int currentUserId = JwtDecoder.decode(token.toString())['user_id'];
      final userProfile = await UserPreferences().getCurrentUser();
      print(currentUserId);

      final url =
          '${ApiURLs.baseUrl}${ApiURLs.update_user_profile}${currentUserId}/';
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
            {"old_password": oldPassword, "new_password": newPassword}),
      );
      if (response.statusCode == 200) {
        ToastNotifier.showSuccessToast(
            context, "Password Changed Successfully");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                  userProfile: UserProfile(id: userProfile!.id),
                  authToken: token.toString())),
        );
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "There is an Error occured:${e}");
    }
    // Call your API to update the password here
    // On success, navigate to the profile screen or show success message
    //Navigator.pop(context); // Go back to profile or home screen after success
  }

  bool obsecure = false;
  var formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: formkey,
            child: CustomPasswordScreen(
                onPressed: () {
                  if (confirmPasswordController.text == widget.newPassword) {
                    updatePassword(
                        context, widget.oldPassword, widget.newPassword);
                  } else {
                    // Show error message if passwords do not match
                    ToastNotifier.showErrorToast(
                        context, "Password does not match");
                  }
                },
                controller: confirmPasswordController,
                obsecure: obsecure,
                title: "Confirm password!")),
      ),
    );
  }
}
