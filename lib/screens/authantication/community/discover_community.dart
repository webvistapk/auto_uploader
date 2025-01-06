import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/screens/authantication/sign_up_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoverCommunityScreen extends StatelessWidget {
  const DiscoverCommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black,
        // appBar: AppBar(
        //   backgroundColor: AppColors.black,
        //   elevation: 0,
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        //     onPressed: () {
        //       // Handle back navigation
        //       Navigator.pop(context);
        //     },
        //   ),
        // ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                "Discover Community",
                textAlign: TextAlign.center,
                style: AppTextStyles.poppinsBold(
                    fontSize: 24,
                    color: AppColors.white,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 30),
              Text(
                "Add photos, find friends, and join clubs to make the most of Pine.\n\nYour feed will populate with friends and club member content alongside curated picks just for you.",
                textAlign: TextAlign.center,
                style: AppTextStyles.poppinsMedium(
                  fontSize: 16,
                  color: Colors.white70,
                ).copyWith(
                  height: 1.5,
                ),
              ),
              const Spacer(),
              CustomContinueButton(
                buttonText: 'Enter Pine',
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('isAuth', true);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => SignupScreen()),
                      (route) => false);
                },
                isPressed: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
