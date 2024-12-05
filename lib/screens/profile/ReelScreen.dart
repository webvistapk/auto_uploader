import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/screens/profile/widgets/comment_Widget.dart';
import 'package:mobile/screens/profile/widgets/reel_post.dart';
import 'package:provider/provider.dart';
import '../../controller/services/post/post_provider.dart';
import '../../models/ReelPostModel.dart';

class ReelScreen extends StatefulWidget {
  final List<ReelPostModel> reels;
  final int initialIndex; // The index to start from
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
  late PageController _pageController;
  int _currentIndex = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void showComments(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: CommentWidget(
            isUsedSingle: true,
            postId: postId,
            isReelScreen: true,
          ),
        );
      },
    );
  }

  Future<void> deleteReel() async {
    // Call deletePost from the provider
    await Provider.of<PostProvider>(context, listen: false)
        .deletePost(widget.reels[_currentIndex].id.toString(), context, true);

    // Update the reel list and current index
    setState(() {
      widget.reels.removeAt(_currentIndex);

      if (_currentIndex >= widget.reels.length) {
        _currentIndex = widget.reels.isEmpty ? 0 : widget.reels.length - 1;
      }
    });

    // Navigate to the next reel if available
    if (widget.reels.isNotEmpty) {
      _pageController.jumpToPage(_currentIndex);
    }
  }

  void _likePost(int reelId) async {
  setState(() {
    widget.reels[_currentIndex].isLiked = !widget.reels[_currentIndex].isLiked;
  });

  try {
    await Provider.of<PostProvider>(context, listen: false)
        .newLike(reelId, context,true);
  } catch (e) {
    // Revert the like state in case of an error
    setState(() {
      widget.reels[_currentIndex].isLiked =
          !widget.reels[_currentIndex].isLiked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to like reel. Please try again.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
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
          PageView.builder(
            controller: _pageController,
            itemCount: widget.reels.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return ReelPost(
                src: widget.reels[index].file,
              );
            },
          ),
          Positioned(
            right: 20,
            bottom: 80,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _likePost(widget.reels[_currentIndex].id);
                    print("Reel Liked");
                  },
                  child: Icon(
                    widget.reels[_currentIndex].isLiked?
                    Icons.favorite_outline:
                    Icons.favorite,
                    color:widget.reels[_currentIndex].isLiked? AppColors.white:Colors.red,
                    size: 30,
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    showComments(widget.reels[_currentIndex].id.toString());
                  },
                  child: Icon(
                    Icons.messenger,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Share Action
                  },
                  child: Icon(
                    FontAwesomeIcons.share,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle Bookmark Action
                  },
                  child: Icon(
                    Icons.bookmark_outline,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                SizedBox(height: 20),
                if (widget.showEditDeleteOptions)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.white,
                      size: 30,
                    ),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await deleteReel();
                      } else if (value == 'edit') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Edit functionality not implemented.')),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
