import 'package:flutter/material.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/screens/authantication/signup/password.dart';
import 'package:mobile/screens/post/pool/widget/custom_text_field.dart';

class EmailInputScreen extends StatefulWidget {
  final String username;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  const EmailInputScreen(
      {Key? key,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.dateOfBirth})
      : super(key: key);

  @override
  State<EmailInputScreen> createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends State<EmailInputScreen> {
  TextEditingController emailController = TextEditingController();

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    "Enter Your Email",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: emailController,
                    hintText: "example@gmail.com",
                  ),
                  // TextField(
                  //   keyboardType: TextInputType.emailAddress,
                  //   decoration: InputDecoration(
                  //     labelText: "Email",
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                ],
              ),
              CustomContinueButton(
                buttonText: "Continue",
                onPressed: () {
                  if (emailController.text.isEmpty) {
                    // ToastNotifier.showErrorToast(
                    //     context, "Email Field Required");
                  } else if (!emailController.text.contains('@')) {
                    // ToastNotifier.showErrorToast(
                    //     context, "Enter Your Correct Email");
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordInputScreen(
                          dateOfBirth: widget.dateOfBirth,
                          username: widget.username,
                          email: emailController.text.trim(),
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                        ),
                      ),
                    );
                  }
                },
                isPressed: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
