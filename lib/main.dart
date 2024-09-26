import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:mobile/screens/authantication/otp_screen.dart';
=======
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
>>>>>>> df7d1b4963f2123cca0ca4b2a49fc3607022bcf7
import 'package:mobile/screens/profile/loading_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      title: 'Fillet Social Media App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: OtpScreen(), // Start with the LoadingScreen
=======
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
          title: 'Fillet Social Media App',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: LoadingScreen()),
>>>>>>> df7d1b4963f2123cca0ca4b2a49fc3607022bcf7
    );
  }
}
