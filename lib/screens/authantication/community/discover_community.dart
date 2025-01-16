import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';

class DiscoverCommunityScreen extends StatefulWidget {
  final email;
  final UserProfile userProfile;
  final String authToken;
  const DiscoverCommunityScreen(
      {Key? key,
      this.email,
      required this.userProfile,
      required this.authToken})
      : super(key: key);

  @override
  State<DiscoverCommunityScreen> createState() =>
      _DiscoverCommunityScreenState();
}

class _DiscoverCommunityScreenState extends State<DiscoverCommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
              style: TextStyle(
                  fontSize: 24,
                  color: AppColors.black,fontFamily: 'Greycliff CF',
                  fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 30),
            Text(
              "Add photos, find friends, and join clubs to make the most of Pine.\n\nYour feed will populate with friends and club member content alongside curated picks just for you.",
              textAlign: TextAlign.center,
              style: AppTextStyles.poppinsMedium(
                fontSize: 16,
                color: Colors.black87,
              ).copyWith(
                height: 1.5,
              ),
            ),
            const Spacer(),
            CustomContinueButton(
              buttonText: 'Enter Pine',
              onPressed: () async {
                await Prefrences.setDiscoverCommunity(true);
    
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainScreen(
                      email: widget.email ?? "",
                      userProfile: widget.userProfile!,
                      authToken: widget.authToken.toString(),
                    ),
                  ),
                  (route) => false,
                );
              },
              isPressed: true,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
