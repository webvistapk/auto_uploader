import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/screens/widgets/tellus_logo.dart';
import '../widgets/app_logo.dart';
import '../../common/app_styles.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor, // Set greyish background color
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(
                        height:
                            100), // Adjust this value to match the arrow position
                    const AppLogo(
                        width: 80,
                        height:
                            80), // Position the logo higher with smaller size
                    const SizedBox(height: 30),
                    const Text(
                      'Please enter your email and we will send you a password reset link',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Set button background to blue
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              50), // Updated border radius
                        ),
                      ),
                      child: const Text('Submit',
                          style: AppStyles.buttonTextStyle),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back to Login',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const TellusLogo(width: 100, height: 50),
          const SizedBox(
              height:
                  20), // Adjust this value to add some spacing at the bottom if needed
        ],
      ),
    );
  }
}
