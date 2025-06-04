import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/controller/firebase_notification/notification_provider.dart';
import 'package:mobile/controller/firebase_notification/notification_service.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/controller/providers/profile_provider.dart';
import 'package:mobile/controller/services/followers/follower_provider.dart';
import 'package:mobile/controller/services/followers/follower_request.dart';
import 'package:mobile/controller/services/post/comment_provider.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/controller/services/post/tags/tags_provider.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/screens/messaging/controller/chat_controller.dart';
import 'package:mobile/screens/messaging/controller/chat_provider.dart';
import 'package:mobile/screens/notification/controller/notificationProvider.dart';
import 'package:mobile/screens/splash_screen.dart';

// import 'package:mobile/screens/widget/alert_screen.dart';
import 'package:provider/provider.dart';

import 'controller/services/StatusProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar
    statusBarIconBrightness: Brightness.dark, // Dark icons for the status bar
  ));
  // await NotificationService.initializeFCM();
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
        ChangeNotifierProvider(create: (_) => FirebaseNotificationProvider()),
      ],
      child: ScreenUtilInit(
        designSize: Size(889, 1940.71), // Set your Figma design size
        minTextAdapt: true, // ✅ Prevents LateInitializationError
        splitScreenMode: true, // ✅ Handles landscape mode better
        child: GetMaterialApp(
            title: 'Fillet Social Media App',
            theme: ThemeData(
                //  useMaterial3: false,
                // primarySwatch: Colors.green,
                primaryColor: AppColors.white,
                fontFamily: 'Greycliff CF'),
            getPages: AppRoutes.pages,
            home: SplashScreen()),
      ),
    );
  }
}
