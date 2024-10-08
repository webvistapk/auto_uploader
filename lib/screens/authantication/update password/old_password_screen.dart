import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_styles.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/screens/authantication/update%20password/new_password_screen.dart';
import 'package:mobile/screens/authantication/update%20password/widget/custom_widget.dart';

class OldPasswordScreen extends StatefulWidget {
  @override
  State<OldPasswordScreen> createState() => _OldPasswordScreenState();
}

class _OldPasswordScreenState extends State<OldPasswordScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();

  Future<void> checkPassword(BuildContext context, String password) async {
    // Call your API here to verify the old password
    // If success, navigate to NewPasswordScreen
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewPasswordScreen(oldPassword: password)),
    );
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
