import 'package:flutter/material.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/controller/services/followers/follower_request.dart';
import 'package:mobile/screens/profile/loading_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Media Query used to store Size of app
    screenWidth = MediaQuery.of(context).size.width;
    screenWidth = MediaQuery.of(context).size.height;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => follower_request_provider()),
        ChangeNotifierProvider(create: (_) => AuthProvider())
      ],
      child: MaterialApp(
        title: 'Fillet Social Media App',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: LoadingScreen(), // Start with the LoadingScreen
      ),
    );
  }
}
