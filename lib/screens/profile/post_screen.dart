import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/widgets/single_post.dart';

import '../../common/utils.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:  ListView.builder(
        itemCount: 10, // Number of posts
        itemBuilder: (context, index) {
          return PostWidget(
            username: 'kashif_official',
            location: 'Nawabshah, Sindh',
            date: 'Oct 9th 2024',
            caption: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. #developer #flutter',
            postImageUrl: AppUtils.testImage, // Example image URL
            profileImageUrl: AppUtils.testImage, // Example profile URL
            likes: '2.4k',
            comments: '669',
            shares: '129',
            saved: '205',
          );
        },
      ),
    );
  }
}
