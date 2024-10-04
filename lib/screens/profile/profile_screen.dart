import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
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
  int? _userId;
  int? _loggedInUserId;
  Future<FetchResponseModel>? _followRequestsResponse;

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

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
        _userProfile = UserPreferences().getCurrentUser();
        // debugger();
        _isFollowing = _checkIsFollowig(_loggedInUserId!, userId!, token!);
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error decoding token: $e");
      // Handle the error accordingly (e.g., navigate to login screen)
    }
  }

  Future<UserProfile?> _fetchUserProfile(int userId) async {
    // if (widget.userProfile != null) {
    //   return await UserPreferences().getCurrentUser();
    // }
    return await UserService.fetchUserProfile(userId);
  }

  Future<int?> _getUserIdFromToken() async {
    String? token = await Prefrences.getAuthToken();
    if (token != null && token.isNotEmpty) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['user_id'] as int?;
    }
    return null;
  }

  Future<bool> _checkIsFollowig(int userId, int currentId, String token) async {
    try {
      int currentUserId = currentId;

      // Await the asynchronous operation to get the follow request status
      await Provider.of<follower_request_provider>(context, listen: false)
          .fetchFollowRequestStatus(currentUserId, userId, token);

      // After fetching the status, check it and return the corresponding bool value
      if (Provider.of<follower_request_provider>(context, listen: false)
              .status ==
          'accepted') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        onSearch: (query) => SearchStore.updateSearchQuery(query),
      ),
      drawer: const SideBar(),
      backgroundColor: AppColors.mainBgColor,
      body: ValueListenableBuilder<String?>(
        valueListenable: SearchStore.searchQuery,
        builder: (context, searchQuery, child) {
          if (searchQuery == null || searchQuery.isEmpty) {
            return FutureBuilder<UserProfile?>(
              future: _userProfile,
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (profileSnapshot.hasError) {
                  return Center(child: Text('Error: ${profileSnapshot.error}'));
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
                        return const Center(child: CircularProgressIndicator());
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfileHeader(
                                  user: user,
                                  canViewProfile: canViewProfile,
                                  isFollowing: isFollowing),
                              if (canViewProfile) ...[
                                const CategoryIcons(images: [
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                ]),
                                const ProfileImages(images: [
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                  AppUtils.testImage,
                                ]),
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
            );
          } else {
            return SearchWidget(
              query: searchQuery,
              authToken: token!,
            );
          }
        },
      ),
      // bottomNavigationBar: BottomBar(
      //   selectedIndex: 1,
      // ),
    );
  }
}
