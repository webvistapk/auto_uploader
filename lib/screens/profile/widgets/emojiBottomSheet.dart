import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:provider/provider.dart';

void showEmojiBottomSheet(BuildContext context, String chatID, postID) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white, // Use AppColors.white if you have it
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (context) {
      final List<String> emojis = [
        "😂", "😍", "😎",
        "😅", "😆", "🤔",
      ];

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4, // Takes 40% of the screen height
          child: Column(
            children: [
              Container(
                height: 2,
                width: 43.5.sp,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 41.11.sp),
          TextField(
            decoration: InputDecoration(
              hintText: "Search reactions",
              hintStyle: TextStyle(fontSize: 24.sp,color: Color(0xff757474)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xffF8F8F8),
             
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            ),
          ),
              SizedBox(height: 97.sp),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns like in the image
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: ()async {
                        final response=await Provider.of<PostProvider>(context,listen: false).sendChat(context, chatID, postID, emojis[index].toString());
                    if(response!.statusCode==201){
                      Navigator.pop(context, emojis[index]); // Returns selected emoji
                    }
                        
                      },
                      child: Container(
                        width: 227.sp,
                        height: 268.sp,
                        decoration: BoxDecoration(
                          color: Color(0xffF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emojis[index],
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
