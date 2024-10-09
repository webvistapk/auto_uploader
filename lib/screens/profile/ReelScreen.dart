import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/widgets/reel_post.dart';

class ReelScreen extends StatefulWidget {
  const ReelScreen({super.key});

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  final List<String> videos = [
    'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:   Stack(
        fit: StackFit.expand,
        children: [
          //We need swiper for every content
          Swiper(
            itemBuilder: (BuildContext context, int index) {
              return ReelPost(
                src: videos[index],
              );
            },
            itemCount: videos.length,
            scrollDirection: Axis.vertical,
          ),
          Positioned(
            right: 20,
            bottom: 80,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle Like Action
                  },
                  child: Icon(Icons.favorite_outline, color: Colors.white, size: 30,),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Comment Action
                  },
                  child: Icon(Icons.messenger, color: Colors.white, size: 30,),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Comment Action
                  },
                  child: Icon(Icons.share_outlined, color: Colors.white, size: 30),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Share Action
                  },
                  child: Icon(Icons.bookmark_outline, color: Colors.white, size: 30),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                  // Handle Bookmark Action
                 },
                  child: Icon(Icons.more_vert, color: Colors.white, size: 30),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
