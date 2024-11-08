import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/authantication/otp_screen.dart';
import 'package:mobile/screens/post/create_post_screen.dart';
import 'package:mobile/screens/post/widgets/add_post_screen.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/profile/request_screen/request_sereen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final email;
  final UserProfile userProfile;
  final String authToken;
  int selectedIndex;
  MainScreen(
      {super.key,
      this.email,
      required this.userProfile,
      required this.authToken,
      this.selectedIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Loading indicator state

  final List<Widget> _pages = [
    HomeScreen(),
    Center(
        child:
            Text("Waiting for Searching ...", style: TextStyle(fontSize: 24))),
    CreatePostScreen(),
    // CameraScreen(),
    RequestScreen(),
    SizedBox(),
  ];
  int? userID;
  UserProfile? userProfile;
  @override
  void initState() {
    super.initState();
    _checkEmailVerification(); // Trigger the email verification check
  }

  Future<void> _checkEmailVerification() async {
    if (mounted) {
      userID = await Prefrences.getUserId();
      setState(() {
        userProfile = widget.userProfile;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString(Prefrences
        .userEmail); // Retrieve the user's email from shared preferences
    if (widget.email.isNotEmpty || userEmail != null) {
      bool result = await Provider.of<AuthProvider>(context, listen: false)
          .checkEmailVerification(context, userEmail!);

      if (result) {
        // Use the provider to check email verification
      } else {
        ToastNotifier.showErrorToast(
            context, "Please verify your Email First!");
        // Handle case where user email is not found (if needed)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => OtpScreen(
                    userEmail: userEmail,
                  )),
        );
      }
    } else {
      // SharedPreferences prefs = await SharedPreferences.getInstance();

      Navigator.pushAndRemoveUntil(
          context,
          CupertinoDialogRoute(builder: (_) => LoginScreen(), context: context),
          (route) => false);
    }

    // Once verification process is complete, stop the loading indicator
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(builder: (context) {
        var pro = context.watch<AuthProvider>();
        return pro.isLoading
            ? Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : Scaffold(
                body: widget.selectedIndex == 0
                    ? HomeScreen(
                        userProfile: widget.userProfile,
                        token: widget.authToken,
                      )
                    : widget.selectedIndex == 2
                        ? CreatePostScreen(
                            token: widget.authToken,
                            userProfile: widget.userProfile,
                          )
                        : widget.selectedIndex == 4
                            ? ProfileScreen(
                                id: widget.userProfile.id,
                                userProfile: widget.userProfile,
                                authToken: widget.authToken,
                              )
                            : _pages[widget.selectedIndex],
                bottomNavigationBar: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SalomonBottomBar(
                      currentIndex: widget.selectedIndex,
                      onTap: (index) {
                        setState(() {
                          widget.selectedIndex = index;
                        });
                      },
                      items: [
                        /// Home
                        SalomonBottomBarItem(
                          icon: Icon(CupertinoIcons.home),
                          title: Text(""),
                          selectedColor: Colors.teal,
                        ),

                        /// Search
                        SalomonBottomBarItem(
                          icon: Icon(CupertinoIcons.search),
                          title: Text(""),
                          selectedColor: Colors.teal,
                        ),

                        /// Add
                        SalomonBottomBarItem(
                          icon: Icon(CupertinoIcons.add_circled),
                          title: Text(""),
                          selectedColor: Colors.teal,
                        ),

                        /// Notifications
                        SalomonBottomBarItem(
                          icon: Icon(CupertinoIcons.bell),
                          title: Text(""),
                          selectedColor: Colors.teal,
                        ),

                        /// Profile
                        SalomonBottomBarItem(
                          icon: const Icon(CupertinoIcons.person_alt_circle),
                          title: Text(""),
                          selectedColor: Colors.teal,
                        ),
                      ],
                    ),
                  ),
                ),
              );
      }),
    );
  }
}
