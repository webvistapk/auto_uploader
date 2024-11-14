import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/controller/providers/profile_provider.dart';
import 'package:mobile/controller/services/followers/follower_provider.dart';
import 'package:mobile/controller/services/followers/follower_request.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/controller/services/post/tags/tags_provider.dart';
import 'package:mobile/screens/splash_screen.dart';
import 'package:mobile/video_stream_screen.dart';
// import 'package:mobile/screens/widget/alert_screen.dart';
import 'package:provider/provider.dart';

import 'controller/services/StatusProvider.dart';

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
        ChangeNotifierProvider(create: (_) => FollowerRequestProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => TagsProvider()),
        ChangeNotifierProvider(create: (_) => FollowerProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
      ],
      child: MaterialApp(
          title: 'Fillet Social Media App',
          theme: ThemeData(
            primarySwatch: Colors.green,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          home: VideoStreamScreen(
              videoUrl:
                  'http://147.79.117.253:8001/media/reels/VID-20241111-WA0100.mp4')),
    );
  }
}
