import 'package:flutter/material.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'auth_service.dart'; // Import your auth_service.dart file

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking authentication
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == true) {
          // If authenticated, show the protected screen
          return child;
        } else {
          // If not authenticated, redirect to the login screen
          return const LoginScreen();
        }
      },
    );
  }
}
