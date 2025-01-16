import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/screens/profile/widgets/PostGrid.dart';
import 'package:mobile/screens/profile/widgets/profile_info.dart';
import 'package:mobile/screens/widgets/full_screen_image.dart';

import '../../../models/UserProfile/post_model.dart';
import 'ReelPostGrid.dart';

class ProfileImages extends StatefulWidget {
  String userid;
  ProfileImages({
    super.key,
    required this.userid,
  });

  @override
  State<ProfileImages> createState() => _ProfileImagesState();
}

class _ProfileImagesState extends State<ProfileImages> {
  /*// Filter Image Posts
  List<PostModel> getImagePosts(List<PostModel> posts) {
    return posts.where((post) {
      return post.media.isNotEmpty &&
          post.media.any((element) => element.mediaType == 'image');
    }).toList();
  }

// Filter Video Posts
  List<PostModel> getVideoPosts(List<PostModel> posts) {
    return posts.where((post) {
      return post.media.isNotEmpty && post.media[0].mediaType == 'video';
    }).toList();
  }*/

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Column(
        children: [
          Theme(
            data: ThemeData(
              tabBarTheme: TabBarTheme(
                labelColor: Colors.black, // Set the color for the selected tab
                unselectedLabelColor:
                    Colors.grey, // Set the color for unselected tabs
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                      color: Colors.black, width: 2.0), // Indicator color
                ),
              ),
            ),
            child:  TabBar(
              // physics: NeverScrollableScrollPhysics(),
              isScrollable: true,

              labelPadding: EdgeInsets.symmetric(
                horizontal: 18,
              ), // Padding for labels
              indicatorWeight: 1.0,
              tabs: [
                Tab(
                  child: tabText("All"),
                ),
                Tab(
                  child:  tabText("Photos"),
                ),
                Tab(
                  child: tabText("Videos"),
                ),
                Tab(
                  child: tabText("Pages")
                ),
                Tab(
                  child: tabText("Posts")
                ),
                Tab(
                  child: tabText("tagged")
                ),
                Tab(
                  child: tabText("Reel")
                ),
                Tab(
                  child: tabText("Info")
                ),
              ],
            ),
          ),
          // SizedBox(
          //   height: 10,
          // ),
         
          SingleChildScrollView(
            child: SizedBox(
              height: 500, // Adjust height as needed
              child: TabBarView(
                // physics: NeverScrollableScrollPhysics(),

                children: [
                  PostGrid(
                    filterType: "allPost",
                    userId: widget.userid,
                  ), // All Posts
                  PostGrid(
                    filterType: "image",
                    userId: widget.userid,
                  ), // Filtered Image Posts
                  PostGrid(
                    filterType: "video",
                    userId: widget.userid,
                  ), // Filtered Video Posts
                  PostGrid(
                    filterType: "allPost",
                    userId: widget.userid,
                  ), // Placeholder for Pages
                  PostGrid(
                    filterType: "allPost",
                    userId: widget.userid,
                  ),
                  PostGrid(
                    filterType: "allPost",
                    userId: widget.userid,
                  ), // Placeholder for Posts
                  ReelPostGrid(userId: widget.userid),
                  const profile_info(), // Info tab
                ],
              )// Placeholder for Posts

            ),

              /*TabBarView(
                children: [
                  PostGrid(posts: posts),
                  PostGrid(posts: imagePosts),
                  PostGrid(posts: posts),
                  PostGrid(posts: posts),
                  PostGrid(posts: posts),
                  PostGrid(posts: posts),
                  profile_info(),
                ],
              ),*/
            ),

        ],
      ),
    );
  }

  Widget tabText(String text){
    return Text(text,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                          fontSize: 10,
                          color: Color(0XFF010101)
                      )
                    
                  );
  }
}
