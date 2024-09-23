import 'package:flutter/material.dart';
import 'package:mobile/common/app_styles.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/store/search/search_store.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/widgets/bottom_bar.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:mobile/screens/widgets/top_bar.dart';
import 'package:mobile/services/profile/user_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _errorMessage = '';

  Future<void> _changePassword() async {
    final String oldPassword = _oldPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'New password and confirm password do not match.';
      });
      return;
    }

    try {
      await UserService.changePassword(
          oldPassword: oldPassword, newPassword: newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to change password: $e';
      });
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        onSearch: (query) => SearchStore.updateSearchQuery(query),
      ),
      drawer: const SideBar(),
      // bottomNavigationBar: BottomBar(
      //   selectedIndex: 1,
      // ),
      backgroundColor: Utils.mainBgColor,
      body: ValueListenableBuilder<String?>(
        valueListenable: SearchStore.searchQuery,
        builder: (context, searchQuery, child) {
          if (searchQuery == null || searchQuery.isEmpty) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    TextField(
                      controller: _oldPasswordController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Old Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _newPasswordController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'New Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Confirm Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text('Change Password',
                          style: AppStyles.buttonTextStyle),
                    ),
                    const SizedBox(height: 10),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()),
                          (Route<dynamic> route) =>
                              false, // Remove all previous routes
                        );
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          } else {
            return SearchWidget(query: searchQuery);
          }
        },
      ),
    );
  }
}
