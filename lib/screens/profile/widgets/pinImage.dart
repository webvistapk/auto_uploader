import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/utils.dart';

class PinImage extends StatelessWidget {
  const PinImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
Padding(padding: EdgeInsets.all(14.0),
                child: Center(
                  child: Container(
                    width: 43.5.sp,
                    height: 3.sp,
                    color: Color.fromRGBO(152, 152, 152, 1),
                  ),
                ),
                ),
                SizedBox(height: 8,),
          Container(width: double.infinity,
          height: 1.14.sp,
          color: Color.fromRGBO(154, 154, 154, 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  
                  // Header with username
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              child: SizedBox(
                                width: 73.96.sp,
                                height: 73.96.sp,
                                child: Image.network(
                                  AppUtils.userImage,
                    
                                  fit: BoxFit
                                      .cover, // Ensures the image covers the container without distortion
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 7.8.sp,
                            ),
                            Text(
                              "@username",
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: Color.fromRGBO(58, 58, 58, 1),
                              ),
                            ),
                            SizedBox(
                              width: 4.19.sp,
                            ),
                            Text(
                              "2d",
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Color.fromRGBO(103, 107, 107, 1),
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.more_horiz, color: Colors.black),
                      ],
                    ),
                  ),
            
                  // Main Image with interaction buttons
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image.asset('assets/images/girl-image.png'),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Column(
                          children: [
                           
                            Image.asset("assets/icons/heart_outlined.png",width: 41.77.sp,),
                            SizedBox(height: 4),
                            Text('7',
                                style: TextStyle(color: Colors.white, fontSize: 24.sp)),
                            SizedBox(height: 12),
                            Image.asset("assets/icons/comment2_white.png",width: 41.77.sp,),
                            SizedBox(height: 4),
                            Text('549',
                                style: TextStyle(color: Colors.white, fontSize: 24.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
            
                  const SizedBox(height: 8),
            
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile image
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                          child: SizedBox(
                            width: 73.96.sp,
                            height: 73.96.sp,
                            child: Image.network(
                              AppUtils.userImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 7.8.sp),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("@username",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    color: Color.fromRGBO(58, 58, 58, 1),
                                  )),
                              SizedBox(height: 4),
                              // Modified comment section
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "The comment goes here. Users can reply or like this comment. Add more text to test wrapping.",
                                      style: TextStyle(
                                        color: Color.fromRGBO(58, 58, 58, 1),
                                        fontSize: 24.sp,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Image.asset("assets/icons/heart.png",
                                          width: 24.95.sp),
                                      SizedBox(height: 4),
                                      Text("5,499",
                                          style: TextStyle(
                                              color: Color.fromRGBO(66, 66, 66, 1),
                                              fontSize: 13.96.sp)),
                                    ],
                                  ),
                                ],
                              ),
                              Text("Reply",
                                  style: TextStyle(
                                      color: Color.fromRGBO(89, 88, 88, 1),
                                      fontSize: 18.61.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            
                  const SizedBox(height: 4),
            
                  const Divider(height: 20),
            
                 // Add Comment Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                children: [
            // User avatar
            ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          child: SizedBox(
                            width: 64.96.sp,
                            height: 63.96.sp,
                            child: Image.network(
                              AppUtils.userImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
            SizedBox(width: 12),
            // Text field with QR icon
            Expanded(
              child: Container(
                
                decoration: BoxDecoration(
                  color: Color.fromRGBO(248, 248, 248, 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.only(left: 8,right: 0, top: 0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Add Comment",
                          hintStyle: TextStyle(fontSize: 24.sp, color: Color.fromRGBO(117, 116, 116, 1)),
                          border: InputBorder.none,
                          isDense: true,
                          
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 14),
                      onPressed: () {
                        
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
                ],
              ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
