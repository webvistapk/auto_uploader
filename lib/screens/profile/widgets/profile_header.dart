import 'dart:developer';

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
        setState(() {
          refresh();
          print("refresh called");
        });
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
        setState(() {
          refresh();
          print("refresh called");
        });
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

  void refresh() {
    _fetchFollowResponse();
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileContainer(
                    AppUtils.testImage,
                    "${widget.user.firstName.toString()} ${widget.user.lastName.toString()}",
                    widget.user.position ?? "JobType",
                    widget.user.description ?? "description",
                    widget.user.address ?? 'Address',
                    widget.user.city ?? "city",
                    widget.user.country ?? 'country'),
                /*Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FullScreenImage(
                              imageUrl: AppUtils.testImage,
                              tag: "profile-image",
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'profile-image',
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image: NetworkImage(AppUtils.testImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            '${widget.user.firstName.toString()} ${widget.user.lastName.toString()}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (widget.canViewProfile) ...[
                            Text(
                              widget.user.position ?? "",
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.user.description!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.greyColor,
                              ),
                            ),
                            Text(
                              [
                                if (widget.user.address!.isNotEmpty)
                                  widget.user.address,
                                if (widget.user.city!.isNotEmpty)
                                  widget.user.city,
                                if (widget.user.country!.isNotEmpty)
                                  widget.user.country,
                              ].where((part) => part!.isNotEmpty).join(', '),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                AppUtils.launchUrl(widget.user.website!);
                              },
                              child: Text(
                                widget.user.website ?? "",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            const Text(
                              "This profile is private.",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.greyColor,
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),*/
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '@${widget.user.username}',
                      style: const TextStyle(color: AppColors.greyColor),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 16),
                if (isCurrentUser) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(),
                                settings: RouteSettings(arguments: widget.user),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(color: AppColors.whiteColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Share Profile',
                            style: TextStyle(color: AppColors.blackColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Builder(builder: (context) {
                          var provider =
                              context.watch<follower_request_provider>();
                          return ElevatedButton(
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
                                      ? Colors.red
                                      : Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: provider.isFollowLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
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
                      ),

                      /*ElevatedButton(
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
                                      ? Colors.red
                                      : Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              provider.status == 'pending'
                                  ? 'Pending'
                                  : provider.status == 'initial' ||
                                          provider.status == 'rejected'
                                      ? 'Follow'
                                      : 'Unfollow',
                              style:
                                  const TextStyle(color: AppColors.whiteColor),
                            ),
                          ),*/

                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Message',
                            style: TextStyle(color: AppColors.blackColor),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.user.following_count}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Following',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.greyColor),
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
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Followers',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.greyColor),
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
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Posts',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.greyColor),
                        ),
                      ],
                    ),
                  ],
                ),
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
      String img, fullName, JobType, description, address, city, country) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          CircleAvatar(
            radius: header5,
            backgroundImage: NetworkImage(img),
          ),
          const SizedBox(
            width: 40,
          ),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: TextStyle(
                      color: AppColors.greyColor, fontSize: paragraph * 0.55),
                ),
                Text(
                  JobType,
                  style: TextStyle(
                      color: AppColors.darkGrey, fontSize: paragraph * 0.35),
                ),
                Text(
                  description,
                  style: TextStyle(
                      color: AppColors.lightGrey, fontSize: paragraph * 0.35),
                ),
                Text(
                  "${address}, ${city},${country}",
                  style: TextStyle(
                      color: AppColors.darkGrey, fontSize: paragraph * 0.35),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
