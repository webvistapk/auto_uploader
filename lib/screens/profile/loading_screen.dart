import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/profile/mainscreen/main_screen.dart';
import 'package:mobile/screens/profile/login_screen.dart'; // Import the login screen
import 'package:mobile/screens/widgets/tellus_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_logo.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    // Delay to simulate loading
    await Future.delayed(Duration(seconds: 4));

    // Load SharedPreferences and user profile data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = prefs.get(Prefrences.authToken);
    final email = prefs.get(Prefrences.userEmail);
    UserPreferences userPreferences = UserPreferences();

    UserProfile? userProfile = await userPreferences.getCurrentUser();

    if (!mounted) return;

    // Navigate based on auth token availability
    if (data != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            email: email ?? "",
            userProfile: userProfile!,
          ),
        ),
        (route) => false,
      );
    } else {
      Navigator.push(
        context,
        CupertinoDialogRoute(
          builder: (_) => LoginScreen(),
          context: context,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              CircularProgressIndicator.adaptive(),
              TellusLogo(width: 100, height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
