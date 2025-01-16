import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:mobile/screens/profile/FollowerReelScreen.dart';
import 'package:mobile/screens/profile/ReelScreen.dart';
import 'package:mobile/screens/profile/post_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class SideBar extends StatelessWidget {
//   const SideBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       width: MediaQuery.of(context).size.width * .6,
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           const DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Text(
//               'Menu',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//               ),
//             ),
//           ),
//           // ListTile(
//           //   leading: const Icon(Icons.home),
//           //   title: const Text('Home'),
//           //   onTap: () {
//           //     // Navigate to home
//           //     // Navigator.pushReplacementNamed(context, '/');
//           //   },
//           // ),
//           // ListTile(
//           //   leading: const Icon(Icons.account_circle),
//           //   title: const Text('Profile'),
//           //   onTap: () {
//           //     // Navigator.pushReplacementNamed(context, '/profile');
//           //   },
//           // ),
//           ListTile(
//             leading: const Icon(Icons.post_add),
//             title: const Text('Post'),
//             onTap: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => PostScreen()));
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.post_add),
//             title: const Text('Reel'),
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => FollowerReelScreen()));
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Settings'),
//             onTap: () {
//               // Navigate to settings
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.logout_outlined),
//             title: const Text('Logout'),
//             onTap: () async {
//               // Navigate to settings
//               SharedPreferences removeUser =
//                   await SharedPreferences.getInstance();
//               await Prefrences.removeAuthToken();
//               await removeUser.remove(Prefrences.authToken);
//               await UserPreferences().clearCurrentUser();
//               await removeUser.remove(UserPreferences.userKey);
//               await removeUser.clear();
//               ToastNotifier.showSuccessToast(
//                   context, "Logout user Successfully");
//               Navigator.pushAndRemoveUntil(
//                   context,
//                   CupertinoDialogRoute(
//                       builder: (_) => LoginScreen(), context: context),
//                   (route) => false);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
@override
String UserName='';
  void initState(){
    // TODO: implement initState
    super.initState();
      getUserDetail();
      
  }

  getUserDetail()async{
UserPreferences userPreferences = UserPreferences();
      UserProfile? userProfile = await userPreferences.getCurrentUser();
      UserName="${userProfile!.firstName.toString()} " + "${userProfile.lastName.toString()}";
      setState(() {
        
      });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Removes any border radius
      ),
      width: MediaQuery.of(context).size.width * .85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Details Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular avatar
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Image.network(
                    AppUtils.userImage,
                    width: 80,
                  ),
                ),
                const SizedBox(width: 12),
                // User details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      UserName??'',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Greycliff CF',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/profile');
                        print("View Profile");
                        debugPrint("View Profile");
                      },
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // "Manage Groups" link
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Manage Groups',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.grey,
              ),
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: const Text(
                    'Home',
                    style: TextStyle(fontSize: 16,fontFamily: 'Greycliff CF', fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Navigate to Home Screen
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),

                ListTile(
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 16,fontFamily: 'Greycliff CF', fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Navigate to Settings Screen
                    Navigator.pop(context);
                  },
                ),
                //const Divider(thickness: 1, height: 1),
                ListTile(
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,fontFamily: 'Greycliff CF',
                      color: Colors.black,
                    ),
                  ),
                  onTap: () async {
                    // Handle Logout
                    SharedPreferences removeUser =
                        await SharedPreferences.getInstance();
                    await Prefrences.removeAuthToken();
                    await removeUser.remove(Prefrences.authToken);
                    await UserPreferences().clearCurrentUser();
                    await removeUser.remove(UserPreferences.userKey);
                    await removeUser.clear();
                    // ToastNotifier.showSuccessToast(
                    //     context, "Logout user Successfully");
                    Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoDialogRoute(
                            builder: (_) => const LoginScreen(),
                            context: context),
                        (route) => false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
