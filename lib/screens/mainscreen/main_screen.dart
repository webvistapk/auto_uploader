import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/models/ReelPostModel.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/authantication/community/discover_community.dart';
import 'package:mobile/screens/authantication/otp_screen.dart';
import 'package:mobile/screens/messaging/chat_screen.dart';
import 'package:mobile/screens/notification/notificationScreen.dart';
import 'package:mobile/screens/post/create_post_screen.dart';
import 'package:mobile/screens/post/widgets/add_post_screen.dart';
import 'package:mobile/screens/profile/UserReelScreen.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/profile/request_screen/request_sereen.dart';
import 'package:mobile/screens/profile/widgets/ReelPostGrid.dart';
import 'package:mobile/screens/search/widget/search_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final email;
  final UserProfile userProfile;
  final String authToken;
  int selectedIndex;
  MainScreen({
    super.key,
    this.email,
    required this.userProfile,
    required this.authToken,
    this.selectedIndex = 0,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Loading indicator state
  ScrollController scrollController = ScrollController();

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
  int selectedItem = 0;
  @override
  void initState() {
    super.initState();
    initFunctions();
    selectedItem = widget.selectedIndex;
    // Trigger the email verification check
  }

  initFunctions() async {
    bool? isCommunity = await Prefrences.getDiscoverCommunity() ?? null;
    if (isCommunity != null && isCommunity) {
      _checkEmailVerification();
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoDialogRoute(
              builder: (_) => DiscoverCommunityScreen(
                    userProfile: widget.userProfile,
                    authToken: widget.authToken,
                    email: widget.email,
                  ),
              context: context),
          (route) => false);
    }
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
        //ToastNotifier.showErrorToast(
        // context, "Please verify your Email First!");
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
                body: selectedItem == 0
                    ? HomeScreen(
                        userProfile: widget.userProfile,
                        token: widget.authToken,
                      )
                    : selectedItem == 1
                        ? SearchScreen(
                            authToken: widget.authToken,
                          )
                        : selectedItem == 2
                            ? CreatePostScreen(
                                token: widget.authToken,
                                userProfile: widget.userProfile,
                              )
                            : selectedItem == 3
                                ? ChatScreen(
                                    userProfile: widget.userProfile!,
                                  )
                                : selectedItem == 4
                                    ? ProfileScreen(
                                        id: widget.userProfile.id,
                                        userProfile: widget.userProfile,
                                        authToken: widget.authToken,
                                      )
                                    : _pages[selectedItem],
                bottomNavigationBar: SafeArea(
                  child: SalomonBottomBar(
                    backgroundColor: AppColors.deepdarkgreyColor,
                    unselectedItemColor: AppColors.white,
                    selectedItemColor: AppColors.white,
                    selectedColorOpacity: 0,
                    currentIndex: selectedItem,
                    itemPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    onTap: (index) {
                      // if(index==1){
                      // showSearch(context: context, delegate: CustomSearchDelegate());
                      // }
                      // else{

                      setState(() {
                        selectedItem = index;
                      });
                      // }
                    },
                    items: [
                      /// Home
                      _buildBottomBarItem(
                        icon: AppIcons.home,
                        isSelected: selectedItem == 0,
                      ),

                      /// Search
                      _buildBottomBarItem(
                        icon: AppIcons.search,
                        isSelected: selectedItem == 1,
                      ),

                      /// Add
                      _buildBottomBarItem(
                        icon: AppIcons.add_item,
                        isSelected: selectedItem == 2,
                      ),

                      /// Messages
                      _buildBottomBarItem(
                        icon: AppIcons.message,
                        isSelected: selectedItem == 3,
                      ),

                      /// Profile
                      _buildBottomBarItem(
                        icon: AppIcons.profile,
                        isSelected: selectedItem == 4,
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }

  SalomonBottomBarItem _buildBottomBarItem({
    required String icon,
    required bool isSelected,
  }) {
    return SalomonBottomBarItem(
      icon: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            icon,
            height: 20,
          ),
          if (isSelected)
            Positioned(
              bottom: -12, // Adjust the position for the indicator

              child: SizedBox(
                width: 140, // Width of the line
                height: 5,
                child: Container(
                  // Height of the line
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2), // Rounded edges
                  ),
                ),
              ),
            ),
        ],
      ),
      title: const Text(""),
      selectedColor: Colors.teal, // This affects the icon's color when selected
    );
  }
}
