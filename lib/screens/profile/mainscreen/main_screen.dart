import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/profile/request_screen/request_sereen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    RequestScreen(),
    ProfileScreen(),
    Center(child: Text("Settings", style: TextStyle(fontSize: 24))),
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
                  icon: Icon(Icons.home),
                  title: Text(""),
                  selectedColor: Colors.teal,
                ),

                /// Search
                // SalomonBottomBarItem(
                //   icon: Icon(Icons.search),
                //   title: Text("Search"),
                //   selectedColor: Colors.teal,
                // ),

                /// Add

                /// Notifications
                SalomonBottomBarItem(
                  icon: Icon(Icons.notifications),
                  title: Text(""),
                  selectedColor: Colors.teal,
                ),

                /// Profile
                SalomonBottomBarItem(
                  icon: Icon(Icons.person),
                  title: Text(""),
                  selectedColor: Colors.teal,
                ),

                SalomonBottomBarItem(
                  icon: const Icon(
                    Icons.settings,
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
