import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/community/discover_community.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/authantication/login_screen.dart'; // Import the login screen
import 'package:mobile/screens/messaging/controller/chat_provider.dart';
import 'package:mobile/screens/widgets/tellus_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    bool isAuth = prefs.getBool('isAuth') ?? false;
    final data = await Prefrences.getAuthToken();
    // debugger();
    if (data != null && isAuth == true) {
      ChatProvider().setAccessToken(data);
      final email = await Prefrences.getUserEmail();
      UserPreferences userPreferences = UserPreferences();

      UserProfile? userProfile = await userPreferences.getCurrentUser();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            email: email ?? "",
            userProfile: userProfile!,
            authToken: data.toString(),
          ),
        ),
        (route) => false,
      );
    } else if (isAuth == false) {
      Navigator.push(
        context,
        CupertinoDialogRoute(
          builder: (_) => DiscoverCommunityScreen(),
          context: context,
        ),
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

    // debugger();

    // Navigate based on auth token availability
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const Scaffold(
        backgroundColor: AppColors.mainBgColor, // Set greyish background color
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLogo(width: 80, height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
