import 'package:flutter/material.dart';
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
      length: 6,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            labelColor: Colors.black, // Text color when the tab is selected
            unselectedLabelColor:
                Colors.black54, // Text color for unselected tabs (optional)
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Photos'),
              Tab(text: 'Videos'),
              Tab(text: 'Pages'),
              Tab(text: 'Posts'),
              Tab(text: 'Tagged'),
            ],
          ),
          SizedBox(
            height: 500, // Adjust height as needed
            child: TabBarView(
              children: [
                _buildImageGrid(
                    images), // Replace with your methods to build each tab's content
                _buildImageGrid(images),
                _buildImageGrid(images),
                _buildImageGrid(images),
                _buildImageGrid(images),
                _buildImageGrid(images),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> imagesToDisplay) {
    return GridView.builder(
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
