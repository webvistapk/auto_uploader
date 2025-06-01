// // ignore_for_file: must_be_immutable

// import 'package:camera/camera.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile/common/app_colors.dart';
// import 'package:mobile/common/app_icons.dart';
// import 'package:mobile/controller/providers/authentication_provider.dart';
// import 'package:mobile/models/UserProfile/userprofile.dart';
// import 'package:mobile/prefrences/prefrences.dart';
// import 'package:mobile/screens/authantication/email_otp_screen.dart';
// import 'package:mobile/screens/messaging/chat_screen.dart';
// import 'package:mobile/screens/post/create_post_screen.dart';
// import 'package:mobile/screens/post/view/new_post_screen.dart';
// import 'package:mobile/screens/profile/home_screen.dart';
// import 'package:mobile/screens/authantication/login_screen.dart';
// import 'package:mobile/screens/profile/profile_screen.dart';
// import 'package:mobile/screens/profile/request_screen/request_sereen.dart';
// import 'package:mobile/screens/search/widget/search_screen.dart';
// import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MainScreen extends StatefulWidget {
//   final String email;
//   final UserProfile userProfile;
//   final String authToken;
//   int selectedIndex;
//   MainScreen({
//     super.key,
//     this.email = '',
//     required this.userProfile,
//     required this.authToken,
//     this.selectedIndex = 0,
//   });

//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   // Loading indicator state
//   ScrollController scrollController = ScrollController();

//   final List<Widget> _pages = [
//     HomeScreen(),
//     Center(
//         child:
//             Text("Waiting for Searching ...", style: TextStyle(fontSize: 24))),
//     // CreatePostScreen(),
//     // CameraScreen(),
//     AddPostCameraScreen(),
//     RequestScreen(),
//     SizedBox(),
//   ];
//   int? userID;
//   UserProfile? userProfile;
//   int selectedItem = 0;

//   @override
//   void initState() {
//     super.initState();
//     _checkEmailVerification();
//     // initFunctions();
//     selectedItem = widget.selectedIndex;
//     // Trigger the email verification check
//   }

//   // initFunctions() async {
//   //   bool? isCommunity = await Prefrences.getDiscoverCommunity() ?? null;
//   //   if (isCommunity != null && isCommunity) {
//   //   } else {
//   //     Navigator.pushAndRemoveUntil(
//   //         context,
//   //         CupertinoDialogRoute(
//   //             builder: (_) => DiscoverCommunityScreen(), context: context),
//   //         (route) => false);
//   //   }
//   // }

//   Future<void> _checkEmailVerification() async {
//     if (mounted) {
//       userID = await Prefrences.getUserId();
//       setState(() {
//         userProfile = widget.userProfile;
//       });
//     }
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userEmail = prefs.getString(Prefrences
//         .userEmail); // Retrieve the user's email from shared preferences
//     if (widget.email.isNotEmpty || userEmail != null) {
//       bool result = await Provider.of<AuthProvider>(context, listen: false)
//           .checkEmailVerification(context, userEmail!);

//       if (result) {
//         // Use the provider to check email verification
//       } else {
//         //ToastNotifier.showErrorToast(
//         // context, "Please verify your Email First!");
//         // Handle case where user email is not found (if needed)
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (context) => EmailOtpScreen(
//                     userEmail: userEmail,
//                   )),
//         );
//       }
//     } else {
//       // SharedPreferences prefs = await SharedPreferences.getInstance();

//       Navigator.pushAndRemoveUntil(
//           context,
//           CupertinoDialogRoute(builder: (_) => LoginScreen(), context: context),
//           (route) => false);
//     }

//     // Once verification process is complete, stop the loading indicator
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Builder(builder: (context) {
//       var pro = context.watch<AuthProvider>();

//       return pro.isLoading
//           ? Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             )
//           : WillPopScope(
//               onWillPop: () async {
//                 setState(() {
//                   selectedItem = 0;
//                 });
//                 return false;
//               },
//               child: Scaffold(
//                 body: selectedItem == 0
//                     ? HomeScreen(
//                         userProfile: widget.userProfile,
//                         token: widget.authToken,
//                       )
//                     : selectedItem == 1
//                         ? SearchScreen(
//                             authToken: widget.authToken,
//                           )
//                         : selectedItem == 2
//                             ? AddPostCameraScreen()
//                             //  CreatePostScreen(
//                             //     token: widget.authToken,
//                             //     userProfile: widget.userProfile,
//                             //   )
//                             : selectedItem == 3
//                                 ? ChatScreen(
//                                     userProfile: widget.userProfile,
//                                   )
//                                 : selectedItem == 4
//                                     ? ProfileScreen(
//                                         id: widget.userProfile.id,
//                                         userProfile: widget.userProfile,
//                                         authToken: widget.authToken,
//                                       )
//                                     : _pages[selectedItem],
//                 bottomNavigationBar: selectedItem == 2
//                     ? null
//                     : SafeArea(
//                         child: SalomonBottomBar(
//                           backgroundColor: AppColors.deepdarkgreyColor,
//                           unselectedItemColor: AppColors.white,
//                           selectedItemColor: AppColors.white,
//                           selectedColorOpacity: 0,
//                           currentIndex: selectedItem,
//                           itemPadding: EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 12),
//                           onTap: (index) {
//                             // if(index==1){
//                             // showSearch(context: context, delegate: CustomSearchDelegate());
//                             // }
//                             // else{

//                             setState(() {
//                               selectedItem = index;
//                             });
//                             // }
//                           },
//                           items: [
//                             /// Home
//                             _buildBottomBarItem(
//                               icon: AppIcons.home,
//                               isSelected: selectedItem == 0,
//                             ),

//                             /// Search
//                             _buildBottomBarItem(
//                               icon: AppIcons.search,
//                               isSelected: selectedItem == 1,
//                             ),

//                             /// Add
//                             _buildBottomBarItem(
//                               icon: AppIcons.add_item,
//                               isSelected: selectedItem == 2,
//                             ),

//                             /// Messages
//                             _buildBottomBarItem(
//                               icon: AppIcons.message,
//                               isSelected: selectedItem == 3,
//                             ),

//                             /// Profile
//                             _buildBottomBarItem(
//                               icon: AppIcons.profile,
//                               isSelected: selectedItem == 4,
//                             ),
//                           ],
//                         ),
//                       ),
//               ),
//             );
//     });
//   }

//   SalomonBottomBarItem _buildBottomBarItem({
//     required String icon,
//     required bool isSelected,
//   }) {
//     return SalomonBottomBarItem(
//       icon: Stack(
//         alignment: Alignment.bottomCenter,
//         clipBehavior: Clip.none,
//         children: [
//           Image.asset(
//             icon,
//             height: 20,
//           ),
//           if (isSelected)
//             Positioned(
//               bottom: -12, // Adjust the position for the indicator

//               child: SizedBox(
//                 width: 140, // Width of the line
//                 height: 5,
//                 child: Container(
//                   // Height of the line
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(2), // Rounded edges
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       title: const Text(""),
//       selectedColor: Colors.teal, // This affects the icon's color when selected
//     );
//   }
// }

// ignore_for_file: must_be_immutable

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/authantication/email_otp_screen.dart';
import 'package:mobile/screens/messaging/chat_screen.dart';
import 'package:mobile/screens/post/view/add_post_camera.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/profile/request_screen/request_sereen.dart';
import 'package:mobile/screens/search/widget/search_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final String email;
  final UserProfile userProfile;
  final String authToken;
  int selectedIndex;
  MainScreen({
    super.key,
    this.email = '',
    required this.userProfile,
    required this.authToken,
    this.selectedIndex = 0,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ScrollController scrollController = ScrollController();

  int? userID;
  UserProfile? userProfile;
  int selectedItem = 0;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    selectedItem = widget.selectedIndex;
  }

  Future<void> _checkEmailVerification() async {
    if (mounted) {
      userID = await Prefrences.getUserId();
      setState(() {
        userProfile = widget.userProfile;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString(Prefrences.userEmail);

    if (widget.email.isNotEmpty || userEmail != null) {
      bool result = await Provider.of<AuthProvider>(context, listen: false)
          .checkEmailVerification(context, userEmail!);

      if (!result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailOtpScreen(
              userEmail: userEmail,
            ),
          ),
        );
      }
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoDialogRoute(builder: (_) => LoginScreen(), context: context),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var pro = context.watch<AuthProvider>();

    if (pro.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (selectedItem != 0) {
          setState(() {
            selectedItem = 0;
          });
          return false;
        }
        return true; // allow default back behavior on home tab
      },
      child: Scaffold(
        body: _buildPageByIndex(selectedItem),
        bottomNavigationBar: selectedItem == 2
            ? null // Hide bottom nav when camera pushed (handled by Navigator)
            : SafeArea(
                child: SalomonBottomBar(
                  backgroundColor: AppColors.deepdarkgreyColor,
                  unselectedItemColor: AppColors.white,
                  selectedItemColor: AppColors.white,
                  selectedColorOpacity: 0,
                  currentIndex: selectedItem,
                  itemPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  onTap: (index) async {
                    if (index == 2) {
                      // Push camera screen with animation
                      await Navigator.of(context)
                          .push(_createSlideRoute(AddPostCameraScreen(
                        token: widget.authToken,
                        userProfile: widget.userProfile,
                      )));
                      // After pop, return to previous tab (e.g., home)
                      setState(() {
                        selectedItem = 0;
                      });
                    } else {
                      setState(() {
                        selectedItem = index;
                      });
                    }
                  },
                  items: [
                    _buildBottomBarItem(
                      icon: AppIcons.home,
                      isSelected: selectedItem == 0,
                    ),
                    _buildBottomBarItem(
                      icon: AppIcons.search,
                      isSelected: selectedItem == 1,
                    ),
                    _buildBottomBarItem(
                      icon: AppIcons.add_item,
                      isSelected: selectedItem == 2,
                    ),
                    _buildBottomBarItem(
                      icon: AppIcons.message,
                      isSelected: selectedItem == 3,
                    ),
                    _buildBottomBarItem(
                      icon: AppIcons.profile,
                      isSelected: selectedItem == 4,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPageByIndex(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          key: const ValueKey('home'),
          userProfile: widget.userProfile,
          token: widget.authToken,
        );
      case 1:
        return SearchScreen(
          key: const ValueKey('search'),
          authToken: widget.authToken,
        );
      case 3:
        return ChatScreen(
          key: const ValueKey('chat'),
          userProfile: widget.userProfile,
        );
      case 4:
        return ProfileScreen(
          key: const ValueKey('profile'),
          id: widget.userProfile.id,
          userProfile: widget.userProfile,
          authToken: widget.authToken,
        );
      default:
        return const SizedBox.shrink();
    }
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
              bottom: -12,
              child: SizedBox(
                width: 140,
                height: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: const Text(""),
      selectedColor: Colors.teal,
    );
  }

  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // slide from right
        const end = Offset.zero;
        const reverseBegin = Offset.zero;
        const reverseEnd = Offset(-1.0, 0.0); // slide to left on pop

        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        final reverseTween = Tween(begin: reverseBegin, end: reverseEnd)
            .chain(CurveTween(curve: Curves.easeInOut));

        Animation<Offset> offsetAnimation;

        if (animation.status == AnimationStatus.reverse) {
          offsetAnimation = animation.drive(reverseTween);
        } else {
          offsetAnimation = animation.drive(tween);
        }

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
