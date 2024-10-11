import 'package:flutter/material.dart';

import '../post_screen.dart';

class PostGrid extends StatelessWidget {
  final List<Map<String, dynamic>> posts; // Changed to List<Map<String, dynamic>>
  final bool isVideo;

  const PostGrid({
    super.key,
    required this.posts,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index]; // Access the specific post

        return GestureDetector(
          onTap: () {
            // Navigate to PostScreen on tap
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostScreen(), // Pass relevant data if needed
              ),
            );
          },
          child: Hero(
            tag: 'profile_images_$index',
              child:
              Image.network(
                  post['mediaUrl'],
                  fit: BoxFit.cover)
          ),
        );
      },
    );
  }
}
