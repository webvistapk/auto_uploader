import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/screens/profile/widgets/PostGrid.dart';
import 'package:mobile/screens/profile/widgets/ReelPostGrid.dart';
import 'package:mobile/screens/profile/widgets/profile_info.dart';
import 'package:mobile/screens/widgets/full_screen_image.dart';

import '../../../models/UserProfile/post_model.dart';

class ProfileImages extends StatefulWidget {
  String userid;
  final Future<List<PostModel>>? posts;
  final Function(String postID) refresh;
  ProfileImages(
      {super.key,
      //required this.images,
      required this.posts,
      required this.refresh,
      required this.userid,
      });

  @override
  State<ProfileImages> createState() => _ProfileImagesState();
}

class _ProfileImagesState extends State<ProfileImages> {
  List<PostModel> getImagePosts(List<PostModel> posts) {
    return posts.where((post) {
      return post.media[0].mediaType == 'image';
    }).toList();
  }

  // Filter Video Posts
  List<PostModel> getVideoPosts(List<PostModel> posts) {
    return posts.where((post) {
      return post.media[0].mediaType == 'video';
    }).toList();
  }

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
            child: const TabBar(
              isScrollable: true,

              labelPadding: EdgeInsets.symmetric(
                horizontal: 10,
              ), // Padding for labels
              indicatorWeight: 1.0,
              tabs: [
                Tab(
                  child: Text(
                    "All",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    "Photos",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    "Videos",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    "Pages",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    "Posts",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    "Tagged",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    "Reels",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    "Info",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        // Grey border
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Category Name',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 5, horizontal: paragraph * 1.5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ), // Grey border
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 500, // Adjust height as needed
            child: FutureBuilder<List<PostModel>>(
              future: widget.posts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator()); // Loading state
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error loading posts")); // Error state
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No posts available")); // Empty state
                }

                // Data is ready
                List<PostModel> allPosts = snapshot.data!;
                List<PostModel> imagePosts = getImagePosts(allPosts);
                List<PostModel> videoPosts = getVideoPosts(allPosts);
                print("Video List: $videoPosts");
                return TabBarView(
                  children: [
                    PostGrid(
                      posts: allPosts,
                      filterType: "allPost",
                     userId:  widget.userid,
                    ), // All Posts
                    PostGrid(
                        posts: imagePosts,
                        filterType: "image",
                      userId: widget.userid,
                    ), // Filtered Image Posts
                    PostGrid(
                        posts: videoPosts,
                        isVideo: true,
                        filterType: "video",
                      userId:  widget.userid,
                    ), // Filtered Video Posts
                    PostGrid(
                        posts: allPosts,
                        filterType: "allPost",
                      userId: widget.userid,
                    ), // Placeholder for Pages
                    PostGrid(
                        posts: allPosts,
                        filterType: "allPost",
                      userId: widget.userid,
                    ),
                    PostGrid(
                      posts: allPosts,
                      filterType: "allPost",
                      userId: widget.userid,
                    ), // Placeholder for Posts
                    ReelPostGrid(
                        userId: widget.userid
                    ),
                    const profile_info(), // Info tab
                  ],
                );
              },
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
}
