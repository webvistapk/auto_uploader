import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/controller/providers/profile_provider.dart';
import 'package:mobile/controller/services/followers/follower_provider.dart';
import 'package:mobile/controller/services/followers/follower_request.dart';
import 'package:mobile/controller/services/post/comment_provider.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/controller/services/post/tags/tags_provider.dart';
import 'package:mobile/screens/messaging/controller/chat_controller.dart';
import 'package:mobile/screens/messaging/controller/chat_provider.dart';
import 'package:mobile/screens/notification/controller/notificationProvider.dart';
import 'package:mobile/screens/splash_screen.dart';

// import 'package:mobile/screens/widget/alert_screen.dart';
import 'package:provider/provider.dart';

import 'controller/services/StatusProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => ChatController()),
          ChangeNotifierProvider(create: (_) => CommentProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => ReplyProvider()),
        ],
        child: MaterialApp(
            title: 'Fillet Social Media App',
            theme: ThemeData(
              //  useMaterial3: false,
              primarySwatch: Colors.green,
              fontFamily: 'Greycliff CF'
            ),
            home: SplashScreen()));
  }
}
