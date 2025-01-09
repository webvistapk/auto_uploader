import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/screens/authantication/signup/username_screen.dart';
import 'package:intl/intl.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({Key? key}) : super(key: key);

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  DateTime? selectedBirthDate;
  String? formattedBirthDate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
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
              const Spacer(),
              SizedBox(
                height: 300,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime(2000, 1, 1),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      selectedBirthDate = newDateTime;
                      formattedBirthDate =
                          DateFormat('yyyy-MM-dd').format(newDateTime);
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              CustomContinueButton(
                buttonText: "Continue",
                onPressed: selectedBirthDate != null
                    ? () {
                        // Log or use the formatted date
                        print("Selected Birth Date: $formattedBirthDate");

                        Navigator.push(
                          context,
                          CupertinoDialogRoute(
                            builder: (_) => CreateUsernameScreen(
                              dateOfBirth: formattedBirthDate ?? '',
                            ),
                            context: context,
                          ),
                        );
                      }
                    : null,
                isPressed: selectedBirthDate != null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
