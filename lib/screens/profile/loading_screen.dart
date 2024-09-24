import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/screens/widgets/tellus_logo.dart';
import 'package:mobile/screens/profile/login_screen.dart'; // Import the login screen
import '../widgets/app_logo.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });

    return const Scaffold(
      backgroundColor: AppColors.mainBgColor, // Set greyish background color
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 55,
              ),
              AppLogo(width: 80, height: 80),
              // SizedBox(height: 20),
              Spacer(),
              TellusLogo(width: 100, height: 50)
            ],
          ),
        ),
      ),
    );
  }
}
