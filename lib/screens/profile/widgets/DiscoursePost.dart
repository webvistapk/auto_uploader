import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/screens/advance_video_player.dart';

class DiscoursePost extends StatefulWidget {
  final List<String> mediaUrls;
  final String content;
   final bool isVideo;
   final onPressed;

  const DiscoursePost({
    Key? key,
    required this.mediaUrls,
    required this.content,
    required this.isVideo,
    required this.onPressed
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
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(0),
          topRight: Radius.circular(8),
          topLeft: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Media Section
          if (widget.mediaUrls.isNotEmpty)
           GestureDetector(
            onTap: widget.onPressed,
             child: widget.isVideo
                    ? _buildVideoPlayer(widget.mediaUrls[0])
                    :_buildDiscourseImageCarousel(widget.mediaUrls),
           ),
          
           

          // Post Content
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.content,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 24.sp,
                fontFamily: 'fontMedium',
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscourseImageCarousel(List<String> mediaUrls) {
    return CarouselSlider.builder(
      itemCount: mediaUrls.length,
      itemBuilder: (context, index, realIndex) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            mediaUrls[index],
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      },
      options: CarouselOptions(
        height: 300, // You can adjust height as needed
        viewportFraction: 1.0,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        autoPlay: false,
      ),
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 400,
            child: VideoPlayerWidget(videoUrl: videoUrl),
          ),
          
        ],
      ),
    );
  }
}
