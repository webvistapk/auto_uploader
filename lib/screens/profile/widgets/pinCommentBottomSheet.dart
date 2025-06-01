import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';

void showPinCommentBottomSheet(BuildContext context, String userProfile) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 43.3.sp,
                height: 2,
                color: Color(0xff989898),
              ),
              SizedBox(
                height: 55.42.sp,
              ),
              Divider(
                color: Color(
                  0xff9B9A9A,
                ),
                thickness: 0.5.sp,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                userProfile != null
                                    ? userProfile
                                    : AppUtils.userImage,
                                width: 57.89.sp,
                                height: 57.8.sp,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '@username1',
                              style:
                                  TextStyle(fontSize: 24.sp, fontFamily: "fontBold"),
                            ),
                            SizedBox(
                              width: 16.89.sp,
                            ),
                            Text(
                              '2d',
                              style: TextStyle(
                                  fontSize: 18.sp, color: Color(0xff676B6B)),
                            ),
                          ],
                        ),
                                    
                        // Post Image
                        Container(
                          width: double.infinity,
                          height: 846.64.sp, // Adjust height as needed
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4jwllqfo8Yvt0v5mpLhvJLWaAeoVzQ_aFHA&s"), // Replace with actual image
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                                     SizedBox(height: 8),
                        // Comment Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                userProfile != null
                                    ? userProfile
                                    : AppUtils.userImage,
                              ), // Replace with actual image
                              radius: 15,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'username',
                                    style: TextStyle(fontSize: 24.sp, fontFamily: "fontBold"),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'The comment goes here. Users can reply or like this comment.',
                                    style: TextStyle(fontSize: 24.sp, fontFamily: "fontMedium")
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Reply',
                                    style: TextStyle(
                                      color: Color(0xff595858),
                                      fontSize: 18.sp,
                                      fontFamily: 'fontMedium',
                                      
                                      ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 20,),
                                Image.asset(AppIcons.heart,width: 30.95.sp,),
                                Text("0",style: TextStyle(
                                  fontSize: 18.sp,
                                  fontFamily: 'fontMedium'
                                ),)
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
              
                  Divider(
              color: Color(
                0xff9B9A9A,
              ),
              thickness: 0.5.sp,
                          ),
              
                  // Add Comment Input Field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          userProfile != null
                              ? userProfile
                              : AppUtils.userImage,
                          width: 57.89.sp,
                          height: 57.8.sp,
                          fit: BoxFit.cover,
                        ),
                      ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Add Comment',
                              hintStyle: TextStyle(
                                fontSize: 24.sp,
                                color: Color(0xff757474)
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.all(5),
                              fillColor: Color(0xffF8F8F8),
                              filled: true,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(AppIcons.cross,width: 20.94.sp,height: 14.93.sp,),
                              ),
                              suffixIconConstraints: BoxConstraints(
                                
                                minHeight: 14.93.sp,
                                 
                                minWidth: 14.93.sp
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      );
    },
  );
}
