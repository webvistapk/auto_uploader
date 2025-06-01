import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_styles.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/controller/firebase_notification/notification_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/widgets/tellus_logo.dart';
import 'package:provider/provider.dart';

class CheckLoginInfoScreen extends StatefulWidget {
  final UserProfile userProfile;
  final String authToken;
  const CheckLoginInfoScreen(
      {super.key, required this.userProfile, required this.authToken});

  @override
  State<CheckLoginInfoScreen> createState() => _CheckLoginInfoScreenState();
}

class _CheckLoginInfoScreenState extends State<CheckLoginInfoScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<FirebaseNotificationProvider>();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Builder(builder: (context) {
      var pro = context.watch<FirebaseNotificationProvider>();
      return Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Save your login info?',
                style: AppTextStyles.poppinsBold(fontSize: 22),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  "Enable the Save Login Info option to securely store your credentials within the app. This feature ensures a faster and seamless login experience while keeping your data safe and protected. You won't need to re-enter your username or password every time you access the app. Enjoy convenience with security at your fingertips!",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.poppinsRegular(),
                ),
              ),
              TellusLogo(),
              Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await Prefrences.setLoginInfoSave(true);
                  await pro.firebaseNotificationTokenSave(widget.authToken);

                  Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoDialogRoute(
                          builder: (_) => MainScreen(
                              userProfile: widget.userProfile,
                              authToken: widget.authToken),
                          context: context),
                      (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: pro.isLoading
                    ? Center(child: CircularProgressIndicator.adaptive())
                    : Text('Save', style: AppStyles.buttonTextStyle),
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () async {
                  await Prefrences.setLoginInfoSave(false);
                  Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoDialogRoute(
                          builder: (_) => MainScreen(
                              userProfile: widget.userProfile,
                              authToken: widget.authToken),
                          context: context),
                      (route) => false);
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
                child: Text(
                  'Not now',
                  style: AppTextStyles.poppinsBold(
                      color: Colors.blue, fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      );
    }));
  }
}
