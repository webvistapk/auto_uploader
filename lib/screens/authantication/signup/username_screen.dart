import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/screens/authantication/signup/fisrt_last_name.dart';

class CreateUsernameScreen extends StatefulWidget {
  final String dateOfBirth;
  const CreateUsernameScreen({Key? key, required this.dateOfBirth})
      : super(key: key);

  @override
  State<CreateUsernameScreen> createState() => _CreateUsernameScreenState();
}

class _CreateUsernameScreenState extends State<CreateUsernameScreen> {
  TextEditingController usernameController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  bool isButtonEnabled = false; // Button state

  @override
  void initState() {
    super.initState();
    // Listen to changes in the text field
    usernameController.addListener(() {
      setState(() {
        isButtonEnabled = usernameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    usernameController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allows resizing to avoid keyboard overlap
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  createUsername(context, usernameController),
                  CustomContinueButton(
                    buttonText: "Continue",
                    onPressed: isButtonEnabled
                        ? () {
                            if (formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                CupertinoDialogRoute(
                                  builder: (_) => FirstNameLastNameScreen(
                                    dateOfBirth: widget.dateOfBirth,
                                    username: usernameController.text.trim(),
                                    formKey: formKey,
                                  ),
                                  context: context,
                                ),
                              );
                            }
                          }
                        : null, // Disable the button when username is empty
                    isPressed: isButtonEnabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createUsername(BuildContext context, TextEditingController username) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Create a username",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: MediaQuery.of(context).size.width * 0.80,
          child: TextFormField(
            controller: username,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (val) {
              if (usernameController.text.isEmpty) {
                return "Please enter a username";
              }
              return null;
            },
            textAlign: TextAlign.center, // Align input text to the center
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 12), // Padding inside
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 16),
        const Text(
          "This can be changed later",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
