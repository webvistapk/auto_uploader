import 'package:flutter/material.dart';
import 'package:mobile/screens/authantication/otp_screen.dart';
import 'package:mobile/screens/profile/loading_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fillet Social Media App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: OtpScreen(), // Start with the LoadingScreen
    );
  }
}
