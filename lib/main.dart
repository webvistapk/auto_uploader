import 'package:flutter/material.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/screens/profile/loading_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
    );
  }
}
