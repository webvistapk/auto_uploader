import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/widgets/reel_post.dart';

class ReelScreen extends StatefulWidget {
  final List<String> posts; // List of reel video URLs or data
  final int initialIndex; // Index of the reel to start with

  const ReelScreen({
    Key? key,
    required this.posts,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  late SwiperController _swiperController; // Controller for Swiper

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();
    // Set the initial index to be shown by Swiper
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _swiperController.move(widget.initialIndex, animation: false);
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Swiper(
            controller: _swiperController, // Assign the SwiperController
            itemBuilder: (BuildContext context, int index) {
              return ReelPost(
                src: widget.posts[index],
              );
            },
            itemCount: widget.posts.length,
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
                  child: Icon(Icons.favorite_outline, color: Colors.white, size: 30),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Comment Action
                  },
                  child: Icon(Icons.messenger, color: Colors.white, size: 30),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Share Action
                  },
                  child: Icon(Icons.share_outlined, color: Colors.white, size: 30),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Bookmark Action
                  },
                  child: Icon(Icons.bookmark_outline, color: Colors.white, size: 30),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle More Action
                  },
                  child: Icon(Icons.more_vert, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
