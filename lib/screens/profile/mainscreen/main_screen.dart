import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/authantication/otp_screen.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/profile/request_screen/request_sereen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  final accessToken;
  const MainScreen({super.key, required this.accessToken});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    Center(
        child:
            Text("Waiting for Seaching ...", style: TextStyle(fontSize: 24))),
    Center(
        child:
            Text("Waiting for Add Post ...", style: TextStyle(fontSize: 24))),
    RequestScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

                /// Notifications
                SalomonBottomBarItem(
                  icon: Icon(CupertinoIcons.add_circled),
                  title: Text(""),
                  selectedColor: Colors.teal,
                ),

                /// Profile
                SalomonBottomBarItem(
                  icon: Icon(CupertinoIcons.bell),
                  title: Text(""),
                  selectedColor: Colors.teal,
                ),

                SalomonBottomBarItem(
                  icon: const Icon(
                    CupertinoIcons.person_alt_circle,
                  ),
                  title: Text(""),
                  selectedColor: Colors.teal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
