import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/screens/authantication/signup/fisrt_last_name.dart';

class CreateUsernameScreen extends StatefulWidget {
  const CreateUsernameScreen({Key? key}) : super(key: key);

  @override
  State<CreateUsernameScreen> createState() => _CreateUsernameScreenState();
}

class _CreateUsernameScreenState extends State<CreateUsernameScreen> {
  TextEditingController usernameController = TextEditingController();
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                createUsername(context, usernameController),
                CustomContinueButton(
                  buttonText: "Continue",
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoDialogRoute(
                            builder: (_) => FirstNameLastNameScreen(),
                            context: context));
                  },
                  isPressed: true,
                ),
              ],
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
          height: 40,
          child: TextField(
            controller: username,
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
        // const Text(
        //   "Available",
        //   style: TextStyle(
        //     color: Colors.green,
        //     fontSize: 14,
        //   ),
        // ),
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
