import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/otp_screen.dart';
import 'package:mobile/screens/profile/mainscreen/main_screen.dart';
import 'package:mobile/screens/widgets/tellus_logo.dart';
import 'package:mobile/screens/profile/login_screen.dart'; // Import the login screen
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_logo.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 4), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final data = prefs.get(Prefrences.authToken);
      final email = prefs.get(Prefrences.userEmail);
      UserPreferences userPreferences = UserPreferences();

      UserProfile? userProfile;

      userPreferences.getCurrentUser().then((value) {
        setState(() {
          userProfile = value;
        });
      });

      if (data != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => MainScreen(
                      email: email ?? "",
                      userProfile: userProfile!,
                    )),
            (route) => false);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });

    return const Scaffold(
      backgroundColor: AppColors.mainBgColor, // Set greyish background color
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppLogo(width: 80, height: 80),
              // SizedBox(height: 20),
              Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              TellusLogo(width: 100, height: 50)
            ],
          ),
        ),
      ),
    );
  }
}
