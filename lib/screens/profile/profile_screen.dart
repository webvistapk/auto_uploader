import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/followers.dart';
import 'package:mobile/controller/store/search/search_store.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/profile/widgets/category_icons.dart';
import 'package:mobile/screens/profile/widgets/profile_header.dart';
import 'package:mobile/screens/profile/widgets/profile_images.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:mobile/screens/widgets/top_bar.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import '../../controller/services/followers/follower_request.dart';
import '../../models/UserProfile/post_model.dart';

class ProfileScreen extends StatefulWidget {
  final int? id; // Accepts an optional ID
  final UserProfile? userProfile;
  final authToken;
  const ProfileScreen(
      {super.key, required this.id, this.userProfile, this.authToken});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserProfile?>? _userProfile;
  Future<bool>? _isFollowing;
  int? _loggedInUserId;
  Future<FetchResponseModel>? _followRequestsResponse;
  String? userName;
  /*List<Map<String, dynamic>> posts = [];
  Future<List<PostModel>>? _posts;
  int limit = 10;
  int offset = 0;*/

  @override
  void initState() {
    // _getUserIdFromToken();
    _initializeData();
   /* _fetchPosts();*/
    super.initState();
  }

  /*void _fetchPosts() async {
    // images and videos fetch and simulated from an API
    setState(() {
      _posts = Provider.of<PostProvider>(context, listen: false)
          .getPost(context, widget.id.toString(), limit, offset);
    });
  }*/

  String? token;
  Future<void> _initializeData() async {
    try {
      token = await Prefrences.getAuthToken();
      int? userId = widget.id;
      // Ensure the token is not null or empty
      if (token == null || token!.isEmpty) {
        throw FormatException("Invalid or empty token.");
      }

      // debugger();
      if (userId == null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
        userId = decodedToken['user_id'];
      }

      // Check if the token is expired before decoding

      if (userId != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
        _loggedInUserId = decodedToken['user_id'];
      }

      // Decode the token safely
      // debugger();

      if (userId != _loggedInUserId) {
        _userProfile = _fetchUserProfile(userId!);
        // debugger();
        _isFollowing = _checkIsFollowig(userId, _loggedInUserId!, token!);
        setState(() {});
      } else {
        _userProfile = _fetchUserProfile(widget.userProfile!.id);
        // debugger();
        _userProfile!
            .then((value) => UserPreferences().saveCurrentUser(value!));

        _isFollowing = _checkIsFollowig(_loggedInUserId!, userId!, token!);
        setState(() {});
      }
    } catch (e) {
      // debugger();
      debugPrint("Error decoding token: $e");
      // Handle the error accordingly (e.g., navigate to login screen)
    }
  }

  Future<UserProfile?> _fetchUserProfile(int userId) async {
    // if (widget.userProfile != null) {
    //   return await UserPreferences().getCurrentUser();
    // }
    print("THIS is User ID: ${userId}");
    UserProfile? userProfile = await UserService.fetchUserProfile(userId);
    setState(() {
      userName = userProfile.username; // Assign the user's name to the variable
    });
    return userProfile;
  }

  /*_getUserIdFromToken() async {
    String? token = await Prefrences.getAuthToken();
    if (token != null && token.isNotEmpty) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['user_id'];
    }
    return 0;
  }*/

  Future<bool> _checkIsFollowig(int userId, int currentId, String token) async {
    try {
      int currentUserId = currentId;
      // debugger();
      // Await the asynchronous operation to get the follow request status
      await Provider.of<FollowerRequestProvider>(context, listen: false)
          .fetchFollowRequestStatus(currentUserId, userId, token);
      // debugger();
      // After fetching the status, check it and return the corresponding bool value
      if (Provider.of<FollowerRequestProvider>(context, listen: false).status ==
          'accepted') {
        // debugger();
        return true;
      } else {
        // debugger();
        return false;
      }
    } catch (e) {
      // debugger();
      return false;
    }
  }

  /*Future<void> _refresh() async {
    // Refresh logic here, for example, fetching new data
   *//* _fetchPosts();*//*
    // You can add a small delay to simulate a network call if necessary
    await Future.delayed(Duration(milliseconds: 400));
  }*/

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      print(_loggedInUserId);
      return SafeArea(
        child: Scaffold(
          appBar: _loggedInUserId != widget.id
              ? AppBar(
                  title: Text(
                    userName ?? '',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.greyColor),
                  ),
                  centerTitle: true,
                )
              : AppBar(),
          // PreferredSize(
          //     preferredSize: Size.fromHeight(50.0),
          //     child: TopBar(
          //       onSearch: (query) => SearchStore.updateSearchQuery(query),
          //     ),
          //   ),
          drawer: const SideBar(),
          drawerEnableOpenDragGesture: true,
          backgroundColor: AppColors.mainBgColor,
          body: FutureBuilder<UserProfile?>(
            future: _userProfile,
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (profileSnapshot.hasError) {
                return Center(
                    child: Text('Error: ${profileSnapshot.error}'));
              } else if (!profileSnapshot.hasData ||
                  profileSnapshot.data == null) {
                return const Center(child: Text('No user profile found.'));
              } else {
                final UserProfile user = profileSnapshot.data!;
                // debugger();
                return FutureBuilder<bool>(
                  future: _isFollowing,
                  builder: (context, followSnapshot) {
                    if (followSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    } else if (followSnapshot.hasError) {
                      return const Center(
                          child: Text('Error checking follow status.'));
                    } else {
                      final bool isFollowing = followSnapshot.data ?? false;
                      final bool isOwner = _loggedInUserId == user.id;
                      final bool canViewProfile = isOwner ||
                          isFollowing ||
                          user.privacy == AppUtils.privacy_public;
                      // debugger();

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            /* if (_loggedInUserId != widget.id)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.arrow_back),
                                    ),
                                  ),*/
                            ProfileHeader(
                                token: widget.authToken,
                                user: user,
                                canViewProfile: canViewProfile,
                                isFollowing: isFollowing),
                            if (canViewProfile) ...[
                              /* const CategoryIcons(images: [
                                    AppUtils.testImage,
                                    AppUtils.testImage,
                                    AppUtils.testImage,
                                    AppUtils.testImage,
                                    AppUtils.testImage,
                                    AppUtils.testImage,
                                  ]),*/
                              ProfileImages(
                                userid: widget.id.toString(),
                              ),
                            ] else ...[
                              const Center(
                                child: Text("This profile is private."),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),
          // bottomNavigationBar: BottomBar(
          //   selectedIndex: 1,
          // ),
        ),
      );
    });
  }
}
