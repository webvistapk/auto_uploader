import 'package:get/get.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:mobile/screens/authantication/sign_up_screen.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/messaging/inbox.dart';
import 'package:mobile/screens/notification/notificationScreen.dart';
import 'package:mobile/screens/post/create_post_screen.dart';
import 'package:mobile/screens/profile/ReelScreen.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/profile/post_screen.dart';
import '../screens/messaging/chat_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String notification = '/notification';
  static const String posts = '/posts';
  static const String postDetail = '/post_detail';
  static const String createPost = '/create_post';
  static const String comment = '/comment';
  static const String reels = '/reels';
  static const String inbox = '/inbox';
  static const String chats = '/chats';
  static const String userProfile = '/user_profile';
  static const String editProfile = '/edit_profile';
  static const String settings = '/settings';
  static const String explore = '/explore';
  static const String search = '/search';
  static const String friendRequests = '/friend_requests';
  static const String friendsList = '/friends_list';
  static const String groups = '/groups';
  static const String stories = '/stories';
  static const String marketplace = '/marketplace';
  static const String events = '/events';
  static const String liveStream = '/live_stream';

  static Future<UserProfile?> userProfileModel =
      UserPreferences().getCurrentUser();
  static UserProfile? userData = getUser();

  static UserProfile? getUser() {
    UserProfile? userData;

    userProfileModel.then((value) => userData = value);

    return userData;
  }

  static List<GetPage> pages = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: notification, page: () => NotificationScreen()),
    GetPage(name: posts, page: () => PostScreen()),
    GetPage(
        name: postDetail,
        page: () => MainScreen(
              authToken: Prefrences.getAuthToken(),
              userProfile: userData!,
            )),
    GetPage(
        name: createPost,
        page: () => CreatePostScreen(
              isChatCamera: false,
            )),
    // GetPage(
    //     name: comment,
    //     page: () => CommentScreen(postId: Get.parameters['postId'] ?? '')),
    GetPage(name: reels, page: () => ReelScreen(isUserScreen: false)),
    GetPage(
      name: inbox,
      page: () => InboxScreen(
        userProfile: userData!,
        chatModel: Get.arguments['chatModel'],
        chatName: Get.arguments['chatName'],
        participantImage: Get.arguments['participantImage'],
        isNotification: Get.arguments['isNotification'] ?? false,
      ),
    ),
    GetPage(
        name: chats,
        page: () => ChatScreen(
              userProfile: userData!,
            )),
    GetPage(
        name: userProfile,
        page: () => MainScreen(
              authToken: Prefrences.getAuthToken(),
              userProfile: userData!,
              selectedIndex: 4,
            )),
    GetPage(name: editProfile, page: () => EditProfileScreen()),
    // GetPage(name: settings, page: () => SettingsScreen()),
    // GetPage(name: explore, page: () => ExploreScreen()),
    // GetPage(name: search, page: () => SearchScreen()),
    // GetPage(name: friendRequests, page: () => FriendRequestsScreen()),
    // GetPage(name: friendsList, page: () => FriendsListScreen()),
    // GetPage(name: groups, page: () => GroupsScreen()),
    // GetPage(name: stories, page: () => StoriesScreen()),
    // GetPage(name: marketplace, page: () => MarketplaceScreen()),
    // GetPage(name: events, page: () => EventsScreen()),
    // GetPage(name: liveStream, page: () => LiveStreamScreen()),
  ];
}
