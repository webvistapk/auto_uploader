import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/custom_social_button.dart';
import 'package:mobile/screens/authantication/community/discover_community.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:mobile/screens/authantication/signup/birthday_screen.dart';
import 'package:mobile/screens/authantication/signup/phone/phone_input.dart';
import 'package:mobile/screens/widgets/app_logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fixed Header
              const SizedBox(height: 20),
              Text(
                "Sign up for Pine",
                style: AppTextStyles.poppinsBold(
                    fontSize: 25, fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                height: 50,
              ),
              // Scrollable content (form and fields)
              CustomSocialButton(
                textTitle: 'Continue with Email',
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoDialogRoute(
                        builder: (_) => DiscoverCommunityScreen(),
                        context: context),
                  );
                },
              ),
              CustomSocialButton(
                textTitle: 'Continue with Phone',
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     CupertinoDialogRoute(
                  //         builder: (_) => PhoneInputScreen(),
                  //         context: context));
                },
              ),
              CustomSocialButton(textTitle: 'Continue with Apple'),
              CustomSocialButton(textTitle: 'Continue with Google'),

              Spacer(),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Already have an account?',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // Fixed Footer (remains stable when keyboard appears)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoDialogRoute(
                                builder: (_) => LoginScreen(),
                                context: context));
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: Text(
                        'Log in',
                        style: AppTextStyles.poppinsBold(
                            color: Colors.blue, fontWeight: FontWeight.normal),
                      ),
                    ),
                    const AppLogo(width: 150),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
