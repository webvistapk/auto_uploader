import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfile/followers.dart';
import 'package:mobile/store/search/search_store.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/profile/widgets/category_icons.dart';
import 'package:mobile/screens/profile/widgets/profile_header.dart';
import 'package:mobile/screens/profile/widgets/profile_images.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/widgets/bottom_bar.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:mobile/screens/widgets/top_bar.dart';
import 'package:mobile/services/profile/user_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileScreen extends StatefulWidget {
  final int? id; // Accepts an optional ID

  const ProfileScreen({super.key, this.id});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserProfile?>? _userProfile;
  Future<bool>? _isFollowing;
  int? _userId;
  int? _loggedInUserId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    String? token = await Utils.getAuthToken(Utils.authToken);
    _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    final int? passedUserId =
        widget.id ?? ModalRoute.of(context)?.settings.arguments as int?;

    _userId = passedUserId ?? _loggedInUserId;

    setState(() {
      _userProfile = _fetchUserProfile(_userId!);
      _isFollowing = _checkIfFollowing(_userId!);
    });
  }

  Future<UserProfile?> _fetchUserProfile(int userId) async {
    return UserService.fetchUserProfile(userId);
  }

  Future<bool> _checkIfFollowing(int userId) async {
    if (_loggedInUserId != null && userId != _loggedInUserId) {
      try {
        final FollowRequest followRequest =
            await UserService.fetchFollowRequestStatus(
                _loggedInUserId!, userId);

        return followRequest.status == Utils.follower_accepted;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        onSearch: (query) => SearchStore.updateSearchQuery(query),
      ),
      drawer: const SideBar(),
      backgroundColor: Utils.mainBgColor,
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
                            user.privacy == Utils.privacy_public;

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfileHeader(user: user, canViewProfile: canViewProfile, isFollowing: isFollowing),
                              if (canViewProfile) ...[
                                const CategoryIcons(images: [
                                  Utils.testImage,
                                  Utils.testImage,
                                  Utils.testImage,
                                  Utils.testImage,
                                  Utils.testImage,
                                  Utils.testImage,
                                ]),
                                const ProfileImages(images: [
                                  Utils.testImage,
                                  Utils.testImage,
                                  Utils.testImage,
                                  Utils.testImage,
                                  Utils.testImage,
                                  Utils.testImage,
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
            return SearchWidget(query: searchQuery);
          }
        },
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
