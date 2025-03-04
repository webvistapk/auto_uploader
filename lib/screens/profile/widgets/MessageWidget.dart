import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget({super.key});

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
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
            );
  }
}