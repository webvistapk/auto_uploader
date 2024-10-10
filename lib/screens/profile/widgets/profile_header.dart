import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/common/app_snackbar.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/followers/follower_request.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/profile/edit_profile_screen.dart';
import 'package:mobile/screens/widgets/full_screen_image.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:provider/provider.dart';

import '../../../models/UserProfile/followers.dart';

class ProfileHeader extends StatefulWidget {
  final UserProfile user;
  final bool canViewProfile;
  final bool isFollowing;

  const ProfileHeader({
    super.key,
    required this.user,
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
    String? token = await Prefrences.getAuthToken();
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
        Provider.of<follower_request_provider>(context, listen: false)
            .sendfollowRequest(context, currentUserId, widget.user.id);
      } catch (e) {
        // Handle error, e.g., show a snackbar'
        ToastNotifier.showErrorToast(context, "There is an error occured ${e}");
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
        Provider.of<follower_request_provider>(context, listen: false)
            .followRequestResponse(
          context,
          widget.user.id,
          currentUserId,
          "rejected",
        );
      } catch (e) {
        showErrorSnackbar(e.toString(), context);
      }
    }
  }

  void _fetchFollowResponse() async {
    // print("Fetch Called");
    final int? currentUserId = await _getUserIdFromToken();
    _followRequestsResponse =
        Provider.of<follower_request_provider>(context, listen: false)
            .fetchFollowRequestStatus(currentUserId!, widget.user.id, context);
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final int? currentUserId = snapshot.data;
          final bool isCurrentUser = widget.user.id == currentUserId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                profileContainer(
                    AppUtils.testImage,
                    "${widget.user.firstName.toString()} ${widget.user.lastName.toString()}",
                    widget.user.position ?? "JobType",
                    widget.user.address ?? 'Address',
                    widget.user.city ?? "city",
                    widget.user.country ?? 'country'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.user.following_count}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Following',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.greyColor),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24), // Spacing between columns
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.user.followers_count}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Followers',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.greyColor),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24), // Spacing between columns
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Posts',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.greyColor),
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
                              settings: RouteSettings(arguments: widget.user),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
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
                            context.watch<follower_request_provider>();
                        return provider.isLoading?Center(
                          child: CircularProgressIndicator.adaptive(),
                        ):ElevatedButton(
                          onPressed: provider.status == 'pending'
                              ? () {}
                              : provider.status == 'initial' ||
                                      provider.status == 'rejected'
                                  ? _handleFollow
                                  : _handleunfollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: provider.status == 'pending'
                                ? Colors.grey
                                : provider.status == 'initial' ||
                                        provider.status == 'rejected'
                                    ? Colors.blueAccent
                                    : AppColors.lightGrey,
                            padding: EdgeInsets.symmetric(vertical: provider.status=='accepted'?0:8,horizontal: provider.status=='accepted'?0:25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: provider.status=="accepted"?Icon(CupertinoIcons.person_crop_circle,color: AppColors.black,size: 30,):Text(
                                  provider.status == 'pending'
                                      ? 'Pending'
                                      : provider.status == 'initial' ||
                                              provider.status == 'rejected'
                                          ? 'Follow'
                                          : 'Unfollow',
                                  style: const TextStyle(
                                      color: AppColors.whiteColor),
                                ),
                        );
                      }),


                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.lightGrey,
                          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Message',
                          style: TextStyle(color: AppColors.blackColor),
                        ),
                      ),
                    ],
                  )
                ],
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Text(widget.user.website??'www.website.com',style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w100,
                        fontSize: paragraph * 0.32
                      ),),
                      const SizedBox(height: 10),
                      Text(
                          widget.user.description ?? "description",
                        style: TextStyle(
                            color: AppColors.lightGrey, fontSize: paragraph * 0.38),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
              ],
            ),
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
      String img, fullName, JobType,  address, city, country) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            CircleAvatar(
              radius: header5,
              backgroundImage: NetworkImage(img),
            ),
            const SizedBox(
              width: 40,
            ),
            Text(
              fullName,
              style: TextStyle(
                  color: AppColors.greyColor, fontSize: paragraph * 0.52),
            ),
            Text(
              JobType,
              style: TextStyle(
                  color: AppColors.darkGrey, fontSize: paragraph * 0.32),
            ),

            Text(
              "${address}, ${city},${country}",
              style: TextStyle(
                  color: AppColors.darkGrey, fontSize: paragraph * 0.32),
            )
          ],
        ),
      ),
    );
  }
}
