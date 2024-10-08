import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_styles.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/screens/authantication/update%20password/new_password_screen.dart';
import 'package:mobile/screens/authantication/update%20password/widget/custom_widget.dart';

import '../../../common/message_toast.dart';
import '../../../controller/endpoints.dart';
import '../../../prefrences/prefrences.dart';

class OldPasswordScreen extends StatefulWidget {
  @override
  State<OldPasswordScreen> createState() => _OldPasswordScreenState();
}

class _OldPasswordScreenState extends State<OldPasswordScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();

  Future<void> checkPassword(BuildContext context, String password) async {

      try {
        String? email = await Prefrences.getUserEmail();
        final completeUrl = Uri.parse(ApiURLs.baseUrl + ApiURLs.login_endpoint);

        final body = {"username_or_email": email, "password": password};
        final headers = {
          'Content-Type': 'application/json; charset=UTF-8',
          // Add any other necessary headers like Authorization here if required
        };

        Response response = await http.post(completeUrl,
            body: jsonEncode(body), headers: headers);

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewPasswordScreen(oldPassword: password)),
          );
        } else {
          ToastNotifier.showErrorToast(
              context, "Your Current Password is incorrect");
        }
      } catch (e) {
        ToastNotifier.showErrorToast(context, e.toString());

      }

    // Call your API here to verify the old password
    // If success, navigate to NewPasswordScreen

  }

  bool _obscureText = false;
  var formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: formkey,
              child: CustomPasswordScreen(
                  title: "Create password",
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      checkPassword(
                          context, currentPasswordController.text.trim());
                    }
                  },
                  controller: currentPasswordController,
                  obsecure: _obscureText)),
        ),
      )),
    );
  }
}
