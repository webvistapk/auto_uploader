
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/profile/widgets/DiscoursePost.dart';

class DiscourseScreen extends StatefulWidget {
  UserProfile? userProfile;
  DiscourseScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<DiscourseScreen> createState() => _DiscourseScreenState();
}

class _DiscourseScreenState extends State<DiscourseScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            "03/28/23 at 4:58 AM",
            style: TextStyle(
                fontSize: 18.sp, fontFamily: 'fontBold', color: Color(0xff77797A)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 4,
            shrinkWrap: true, // Prevents unbounded height
            // Disable scrolling to avoid conflict
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 48, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "First Lastname",
                            style: TextStyle(
                                fontSize: 24.sp, fontFamily: 'fontBold'),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40.sp, vertical: 12.sp),
                            decoration: BoxDecoration(
                              color: Color(0XFFFF0047),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              "Club Name",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            widget.userProfile!.profileUrl == null
                                ? AppUtils.userImage
                                : "${ApiURLs.baseUrl.replaceAll("/api/", '')}${widget.userProfile!.profileUrl}",
                          ),
                        ),
                        Expanded(
                          child: DiscoursePost(
                              imageUrl:
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4jwllqfo8Yvt0v5mpLhvJLWaAeoVzQ_aFHA&s", // Replace with actual image URL
                              content:
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
                             
                              ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 23.46.sp,
                    ), // User Profile + Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Action Buttons
                        Image.asset(
                          AppIcons.forward,
                          width: 22.6.sp,
                        ),
                        SizedBox(
                          width: 57.74.sp,
                        ),
                        Image.asset(
                          AppIcons.repost,
                          width: 22.6.sp,
                        ),
                        SizedBox(
                          width: 57.74.sp,
                        ),
                        Image.asset(
                          AppIcons.heart_outlined,
                          width: 22.6.sp,
                          color: AppColors.black,
                        ),
                        SizedBox(
                          width: 57.74.sp,
                        ),
                        Image.asset(
                          AppIcons.comment,
                          width: 22.6.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
    
  }
}