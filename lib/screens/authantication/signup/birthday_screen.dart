import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/screens/authantication/community/discover_community.dart';
import 'package:mobile/screens/authantication/signup/username_screen.dart';

class BirthdayScreen extends StatelessWidget {
  const BirthdayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  "What's your birthday?",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.poppinsBold(
                      fontSize: 25, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 20),
                Text(
                  "MM DD YYYY",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.poppinsBold(
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your birthday won't be shown publicly",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.poppinsRegular(),
                ),
                Spacer(),
                SizedBox(
                  height: 300,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime(2000, 1, 1),
                    onDateTimeChanged: (DateTime newDateTime) {
                      // Handle date change
                    },
                  ),
                ),
                const SizedBox(height: 24),
                CustomContinueButton(
                    buttonText: "Continue",
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoDialogRoute(
                              builder: (_) => CreateUsernameScreen(),
                              context: context));
                    }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
