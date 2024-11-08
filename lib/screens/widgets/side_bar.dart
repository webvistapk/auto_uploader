import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:mobile/screens/profile/ReelScreen.dart';
import 'package:mobile/screens/profile/post_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.home),
          //   title: const Text('Home'),
          //   onTap: () {
          //     // Navigate to home
          //     // Navigator.pushReplacementNamed(context, '/');
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.account_circle),
          //   title: const Text('Profile'),
          //   onTap: () {
          //     // Navigator.pushReplacementNamed(context, '/profile');
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.post_add),
            title: const Text('Post'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PostScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.post_add),
            title: const Text('Reel'),
            onTap: () {
              /*Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReelScreen()));*/
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Logout'),
            onTap: () async {
              // Navigate to settings
              SharedPreferences removeUser =
                  await SharedPreferences.getInstance();
              await Prefrences.removeAuthToken();
              removeUser.remove(Prefrences.authToken);
              await UserPreferences().clearCurrentUser();
              await removeUser.remove(UserPreferences.userKey);
              ToastNotifier.showSuccessToast(
                  context, "Logout user Successfully");
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoDialogRoute(
                      builder: (_) => LoginScreen(), context: context),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
