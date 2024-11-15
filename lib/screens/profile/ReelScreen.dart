import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/screens/profile/widgets/reel_post.dart';
import '../../models/ReelPostModel.dart';

class ReelScreen extends StatefulWidget {
  final List<ReelPostModel> reels;
  final int initialIndex;
  final bool showEditDeleteOptions;

  const ReelScreen({
    Key? key,
    required this.reels,
    this.initialIndex = 0,
    this.showEditDeleteOptions = true,
  }) : super(key: key);

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  late SwiperController _swiperController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();
    _currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _swiperController.move(_currentIndex, animation: false);
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
      body: widget.reels.isEmpty
          ? Center(
        child: Text(
          'No Reels Available',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Stack(
        fit: StackFit.expand,
        children: [
          Swiper(
            controller: _swiperController,
            itemBuilder: (BuildContext context, int index) {
              return ReelPost(
                src: widget.reels[index].file, // Access video URL from ReelPostModel
              );
            },
            itemCount: widget.reels.length,
            scrollDirection: Axis.vertical,
            loop: false,
            onIndexChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
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
                  child: Icon(Icons.favorite_outline, color: AppColors.white, size: 30),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Comment Action
                  },
                  child: Icon(Icons.messenger, color: AppColors.white, size: 30),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Share Action
                  },
                  child: Icon(FontAwesomeIcons.share, color: AppColors.white, size: 30),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Bookmark Action
                  },
                  child: Icon(Icons.bookmark_outline, color: AppColors.white, size: 30),
                ),
                SizedBox(height: 20),
                // Conditionally show edit/delete options
                widget.showEditDeleteOptions
                    ? PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.white, size: 30),
                  onSelected: (value) {
                    if (value == 'delete') {
                      // Call delete function
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                )
                    : SizedBox(height: 30), // Reserve space for hidden options
              ],
            ),
          ),
        ],
      ),
    );
  }
}