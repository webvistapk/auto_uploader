import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/screens/authantication/signup/email.dart';
import 'package:mobile/screens/post/pool/widget/custom_text_field.dart';

// Screen 1: First Name and Last Name
class FirstNameLastNameScreen extends StatefulWidget {
  final String username;
  final String dateOfBirth;
  const FirstNameLastNameScreen(
      {Key? key, required this.username, required this.dateOfBirth})
      : super(key: key);

  @override
  State<FirstNameLastNameScreen> createState() =>
      _FirstNameLastNameScreenState();
}

class _FirstNameLastNameScreenState extends State<FirstNameLastNameScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      "Enter Your Name",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: _firstNameController,
                        hintText: "First Name"),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: _lastNameController, hintText: "Last Name")
                  ],
                ),
                CustomContinueButton(
                    buttonText: "Continue",
                    onPressed: () {
                      if (_firstNameController.text.isEmpty ||
                          _lastNameController.text.isEmpty) {
                        //ToastNotifier.showErrorToast(
                        // context, "Please Enter the field required");
                      } else {
                        Navigator.push(
                            context,
                            CupertinoDialogRoute(
                                builder: (_) => EmailInputScreen(
                                      dateOfBirth: widget.dateOfBirth,
                                      username: widget.username,
                                      firstName:
                                          _firstNameController.text.trim(),
                                      lastName: _lastNameController.text.trim(),
                                    ),
                                context: context));
                      }
                    },
                    isPressed: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Screen 2: Email Input


// Screen 3: Password and Confirm Password


