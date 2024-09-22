import 'package:flutter/material.dart';
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
      backgroundColor: Utils.mainBgColor, // Set greyish background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(width: 80, height: 80),
            SizedBox(height: 20),
            TellusLogo(width: 100, height: 50)
          ],
        ),
      ),
    );
  }
}
