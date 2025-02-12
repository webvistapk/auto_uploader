import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';

void showMessageBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (context) {
      return Padding(
       padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16,
            right: 16,
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

            SizedBox(height: 150.sp,),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                  decoration: BoxDecoration(
                      color: Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppIcons.camera, // Change this later
                        width: 33.35.sp,
                        height: 33.34.sp,
                      ),
                      SizedBox(
                        width: 17.31.sp,
                      ),
                      Image.asset(
                        AppIcons.image, // Change this later
                        width: 32.83.sp,
                        height: 32.83.sp,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Send a message..',
                            hintStyle: TextStyle(
                                fontSize: 24.sp, color: Color(0xff757474)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Image.asset(
                        AppIcons.mic, // Change this later
                        width: 32.83.sp,
                        height: 32.83.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 802.sp,
                  height: 76.sp,
                  decoration: BoxDecoration(
                    color: Color(0xff333232),
                    borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(child: Text("Send",style:TextStyle(
                      fontSize: 24.sp,
                      color: AppColors.white
                    ))),
                ),
                
              ],
            ),
           SizedBox(height: 10,)
          ],
        ),
      );
    },
  );
}
