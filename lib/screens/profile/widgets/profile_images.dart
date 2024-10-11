import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/screens/profile/widgets/PostGrid.dart';
import 'package:mobile/screens/profile/widgets/profile_info.dart';
import 'package:mobile/screens/widgets/full_screen_image.dart';

class ProfileImages extends StatelessWidget {
  final List<String> images;
  final List<Map<String, dynamic>> posts;

  const ProfileImages({
    super.key,
    required this.images,
    required this.posts
  });


  //Image Post
  List<String> getImagePosts() {
    return posts
        .where((post) => !post['isVideo']) // Filter for images
        .map((post) => post['mediaUrl'].toString())
        .toList();
  }

  // Video posts
  List<String> getVideoPosts() {
    return posts
        .where((post) => post['isVideo']) // Filter for videos
        .map((post) => post['mediaUrl'].toString())
        .toList();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
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
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: paragraph*1.5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey,), // Grey border
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
            child: TabBarView(
              children: [
                PostGrid(posts: posts),
                PostGrid(posts: posts),
                PostGrid(posts: posts),
                PostGrid(posts: posts),
                PostGrid(posts: posts),
                PostGrid(posts: posts),
                profile_info(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> imagesToDisplay) {
    return GridView.builder(
      // scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imagesToDisplay.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImage(
                    imageUrl: imagesToDisplay[index],
                    tag: "profile_images_$index"),
              ),
            );
          },
          child: Hero(
            tag: 'profile_images_$index', // Unique tag for each image
            child: Image.network(
              imagesToDisplay[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
