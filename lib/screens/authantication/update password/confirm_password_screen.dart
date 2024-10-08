import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/authantication/update%20password/widget/custom_widget.dart';

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
    // Call your API to update the password here
    // On success, navigate to the profile screen or show success message
    Navigator.pop(context); // Go back to profile or home screen after success
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Passwords do not match!")),
                    );
                  }
                },
                controller: confirmPasswordController,
                obsecure: obsecure,
                title: "Confirm password!")),
      ),
    );
  }
}
