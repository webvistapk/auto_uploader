import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/authantication/otp_screen.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/profile/login_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/profile/request_screen/request_sereen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final email;
  final UserProfile userProfile;
  const MainScreen({super.key, this.email, required this.userProfile});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Loading indicator state

  final List<Widget> _pages = const [
    HomeScreen(),
    Center(
        child:
            Text("Waiting for Searching ...", style: TextStyle(fontSize: 24))),
    Center(
        child:
            Text("Waiting for Add Post ...", style: TextStyle(fontSize: 24))),
    RequestScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkEmailVerification(); // Trigger the email verification check
  }

  Future<void> _checkEmailVerification() async {
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
                body: _selectedIndex == 4
                    ? ProfileScreen(
                        userProfile: widget.userProfile,
                      )
                    : _pages[_selectedIndex],
                bottomNavigationBar: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SalomonBottomBar(
                      currentIndex: _selectedIndex,
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
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
