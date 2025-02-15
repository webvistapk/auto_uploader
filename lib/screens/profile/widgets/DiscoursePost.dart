import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';

class DiscoursePost extends StatefulWidget {
  
  final String? imageUrl;
  final String content;

  const DiscoursePost({
    Key? key,
    
    this.imageUrl,
    required this.content,
  }) : super(key: key);

  @override
  State<DiscoursePost> createState() => _DiscoursePostState();
}

class _DiscoursePostState extends State<DiscoursePost> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(0),topRight: Radius.circular(8),topLeft: Radius.circular(8),),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
           // spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          
      
          // Post Image (if available)
          if (widget.imageUrl != null)
            ClipRRect(
              //borderRadius: BorderRadius.circular(0),
              child: Image.network(widget.imageUrl!, 
              width: double.infinity,
              fit: BoxFit.cover),
            ),
      
          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.content,
              style:  TextStyle(fontSize: 24.sp,fontFamily: 'fontMedium', color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
