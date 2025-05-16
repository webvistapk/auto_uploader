import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/screens/profile/widgets/MessageWidget.dart';

void showMessageBottomSheet(BuildContext context, chatId) {
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
            MessageWidget(chatId: chatId,),
           SizedBox(height: 10,)
          ],
        ),
      );
    },
  );
}
