import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/screens/profile/widgets/single_post.dart';

class PostScreen extends StatelessWidget {
  final List<Map<String, dynamic>> posts = [
    {
      'index':1,
      'username': 'kashif_official',
      'location': 'Nawabshah, Sindh',
      'date': 'Oct 9th 2024',
      'caption': 'Beautiful sunset view #nature #photography',
      'mediaUrl': AppUtils.testImage,
      'isVideo': false,
    },
    {
      'index':2,
      'username': 'kashif_official',
      'location': 'Karachi, Sindh',
      'date': 'Oct 8th 2024',
      'caption': 'Enjoying the city life! #urban #explore',
      'mediaUrl': 'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
      'isVideo': true,
    },
    {
      'index':3,
      'username': 'kashif_official',
      'location': 'Lahore, Punjab',
      'date': 'Oct 7th 2024',
      'caption': 'A day at the park with friends #friends #fun',
      'mediaUrl': AppUtils.testImage,
      'isVideo': false,
    },
    {
      'index':4,
      'username': 'kashif_official',
      'location': 'Islamabad, Capital Territory',
      'date': 'Oct 6th 2024',
      'caption': 'Morning run #fitness #motivation',
      'mediaUrl': 'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
      'isVideo': true,
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Posts")),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostWidget(
            username: post['username'],
            location: post['location'],
            date: post['date'],
            caption: post['caption'],
            mediaUrl: post['mediaUrl'],
            profileImageUrl: AppUtils.testImage, // Example profile image
            isVideo: post['isVideo'],
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


