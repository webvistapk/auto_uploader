import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/widgets/profile_info.dart';
import 'package:mobile/screens/widgets/full_screen_image.dart';

class ProfileImages extends StatelessWidget {
  final List<String> images;

  const ProfileImages({
    super.key,
    required this.images,
  });

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
            height: 500, // Adjust height as needed
            child: TabBarView(
              children: [
                _buildImageGrid(images),
                _buildImageGrid(images),
                _buildImageGrid(images),
                _buildImageGrid(images),
                _buildImageGrid(images),
                _buildImageGrid(images),
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
