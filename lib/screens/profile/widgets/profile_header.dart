import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/common/app_snackbar.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/controller/services/followers/follower_request.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/profile/edit_profile_screen.dart';
import 'package:mobile/screens/profile/follower/follower_screen.dart';
import 'package:mobile/screens/profile/following/following_screen.dart';
import 'package:mobile/screens/profile/widgets/profle_edit_screen.dart';
import 'package:mobile/screens/widgets/full_screen_image.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/UserProfile/followers.dart';

class ProfileHeader extends StatefulWidget {
  final UserProfile user;
  final bool canViewProfile;
  final bool isFollowing;
  final token;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.token,
    required this.canViewProfile,
    required this.isFollowing,
  });

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  //bool _followRequestSent = false;
  Future<FetchResponseModel>? _followRequestsResponse;

  Future<int?> _getUserIdFromToken() async {
    final token = await Prefrences.getAuthToken();
    if (token != null && token.isNotEmpty) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['user_id'] as int?;
    }
    return null;
  }

  void _handleFollow() async {
    final int? currentUserId = await _getUserIdFromToken();
    //print("Current User ID : ${currentUserId}");
    //print("User  ID: ${widget.user.id}");
    if (currentUserId != null) {
      try {
        Provider.of<FollowerRequestProvider>(context, listen: false)
            .sendfollowRequest(context, currentUserId, widget.user.id);
      } catch (e) {
        // Handle error, e.g., show a snackbar'
        //ToastNotifier.showErrorToast(context, "There is an error occured ${e}");
      }
    }
  }

  void _handleunfollow() async {
    final int? currentUserId = await _getUserIdFromToken();
    //print("Current User ID : ${currentUserId}");
    //print("User  ID: ${widget.user.id}");
    if (currentUserId != null) {
      try {
        //print("USER ID : ${currentUserId}");

        //print("USER ID 2 : ${widget.user.id}");
        Provider.of<FollowerRequestProvider>(context, listen: false)
            .followRequestResponse(
          context,
          widget.user.id,
          currentUserId,
          "rejected",
        );
      } catch (e) {
        //ToastNotifier.showErrorToast(context, e.toString());
      }
    }
  }

  void _fetchFollowResponse() async {
    // print("Fetch Called");
    final int? currentUserId = await _getUserIdFromToken();
    _followRequestsResponse =
        Provider.of<FollowerRequestProvider>(context, listen: false)
            .fetchFollowRequestStatus(currentUserId!, widget.user.id, context);

    print(_followRequestsResponse);
    // debugger();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchFollowResponse();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getUserIdFromToken(),
      builder: (context, snapshot) {
        // debugger();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final int? currentUserId = snapshot.data;
          final bool isCurrentUser = (widget.user.id == currentUserId);
          // debugger();
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50.0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    profileContainer(
                        widget.user.profileUrl == null
                            ? AppUtils.userImage
                            : ApiURLs.baseUrl + widget.user.profileUrl!,
                        "${widget.user.firstName.toString()} ${widget.user.lastName.toString()}",
                        widget.user.position ?? "",
                        widget.user.address ?? '',
                        widget.user.city ?? "",
                        widget.user.country ?? ''),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                CupertinoDialogRoute(
                                    builder: (_) => FollowingScreen(
                                        token: widget.token??'',
                                        userProfile: widget.user),
                                    context: context));
                          },
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.user.following_count}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.profileFollowColor),
                                ),
                                const Text(
                                  'Following',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: AppColors.profileFollowColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24), // Spacing between columns
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                CupertinoDialogRoute(
                                    builder: (_) => FollowersScreen(
                                        token: widget.token,
                                        userProfile: widget?.user),
                                    context: context));
                          },
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.user?.followers_count}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.profileFollowColor),
                                ),
                                const Text(
                                  'Followers',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: AppColors.profileFollowColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24), // Spacing between columns
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "0",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.profileFollowColor),
                            ),
                            Text(
                              'Views',
                              style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.profileFollowColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isCurrentUser) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(),
                                  settings:
                                      RouteSettings(arguments: widget.user),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(color: AppColors.whiteColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.lightGrey,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Share Profile',
                              style: TextStyle(color: AppColors.blackColor),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Builder(builder: (context) {
                            var provider =
                                context.watch<FollowerRequestProvider>();
                            return provider.isLoading
                                ? Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  )
                                // :InkWell(
                                //   onTap: ,
                                //   child: Container(
                                //     padding: EdgeInsets.all(5),
                                //     decoration: BoxDecoration(
                                //       color: AppColors.profileButtonColor,
                                //       borderRadius: BorderRadius.circular(8)
                                //     ),
                                //     child: Icon(CupertinoIcons.person_crop_circle,
                                //              color: Color(0xFF4A4A4B),
                                //              size: 20,weight: 1,),
                                //   ),
                                // );
                                : GestureDetector(
                                    onTap: provider.status == 'pending'
                                        ? () {}
                                        : provider.status == 'initial' ||
                                                provider.status == 'rejected'
                                            ? _handleFollow
                                            : _handleunfollow,
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                provider.status == 'accepted'
                                                    ? 10
                                                    : 10,
                                            horizontal:
                                                provider.status == 'accepted'
                                                    ? 10
                                                    : 25),
                                        decoration: BoxDecoration(
                                          color: provider.status == 'pending'
                                              ? Colors.grey
                                              : provider.status == 'initial' ||
                                                      provider.status ==
                                                          'rejected'
                                                  ? Colors.blueAccent
                                                  : AppColors
                                                      .profileButtonColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: provider.status == "accepted"
                                            ? Icon(
                                                CupertinoIcons
                                                    .person_crop_circle,
                                                color: AppColors
                                                    .profileTextBlackColor,
                                                size: 20,
                                              )
                                            : Text(
                                                provider.status == 'pending'
                                                    ? 'Pending'
                                                    : provider.status ==
                                                                'initial' ||
                                                            provider.status ==
                                                                'rejected'
                                                        ? 'Follow'
                                                        : 'Unfollow',
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.whiteColor),
                                              )));
                          }),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.profileButtonColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Message',
                              style: TextStyle(
                                  color: AppColors.profileTextBlackColor,
                                  fontSize: 10),
                            ),
                          ),
                        ],
                      )
                    ],
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            widget.user.website ?? '',
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w100,
                                fontFamily: 'Greycliff CF',
                                fontSize: paragraph * 0.32),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            // widget.user.description ??
                            widget.user.description??'',
                            style: TextStyle(
                                color: AppColors.lightGrey, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.profileButtonColor,
                            // Grey border
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Category Name',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                        SizedBox(width: 10),
                        DottedBorder(
                          strokeWidth: 0.5,
                          dashPattern: [11, 6],
                          radius: Radius.circular(12),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 40),
                          color: Color(0xFFBABABA),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.blue,
                              size: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return const Center(
              child: Text('Unable to retrieve user information.'));
        }
      },
    );
  }

  //First Profile Container
  Widget profileContainer(
      String img, fullName, JobType, address, city, country) {
    return Center(
      child: Container(
        // padding: EdgeInsets.all(5),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoDialogRoute(
                    builder: (_) => ProfileEditScreen(
                      authToken: widget.token,
                      imageUrl: img,
                      userProfile: widget.user,
                    ),
                    context: context,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                  width: 50,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: header5 * 2,
                        height: header5 * 2,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error,
                    color: Colors.red,
                    size: header5,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              fullName,
              style: TextStyle(color: AppColors.profileTextColor, fontSize: 10),
            ),
            Text(
              JobType ?? '',
              style: TextStyle(color: AppColors.profileTextColor, fontSize: 10),
            ),
            Text(
              "${address} ${city}${country}",
              style: TextStyle(color: AppColors.profileTextColor, fontSize: 8),
            )
          ],
        ),
      ),
    );
  }
}
