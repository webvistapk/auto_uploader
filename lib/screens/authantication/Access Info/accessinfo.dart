import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccessInfo extends StatelessWidget {
  const AccessInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 114.sp, vertical: 149.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        'Allow Pine to access your camera and microphone',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: "fontBold",
                          color: Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                      SizedBox(height: 178.sp),
                      Padding(
                        padding: EdgeInsets.only(left: 53.sp),
                        child: Column(
                          children: [
                            _buildPermissionItem(
                              title: 'How we\'ll use this',
                              description: 'Description goes here',
                            ),
                            const SizedBox(height: 24),
                            _buildPermissionItem(
                              title: 'How we\'ll use this',
                              description: 'Description goes here',
                            ),
                            const SizedBox(height: 24),
                            _buildPermissionItem(
                              title: 'How we\'ll use this',
                              description: 'Description goes here',
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                     
                    ],
                  ),
                ),
          ),

           Padding(
             padding: EdgeInsets.only(left:33.sp, right: 33.sp, bottom: 74.sp ),
             child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle continue button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:  Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          
                        ),
                      ),
                    ),
                  ),
           ),
           
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: "fontBold",
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
