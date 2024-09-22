import 'package:flutter/material.dart';
import 'auth_service.dart'; // Import your auth_service.dart file

class UnauthGuard extends StatelessWidget {
  final Widget child;

  const UnauthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/');
          });
          return const SizedBox(); // Return an empty widget temporarily
        } else {
          return child;
        }
      },
    );
  }
}
