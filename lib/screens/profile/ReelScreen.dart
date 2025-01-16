import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/controller/function/commentBottomSheet.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/profile/widgets/comment_Widget.dart';
import 'package:mobile/screens/profile/widgets/reel_post.dart';
import 'package:provider/provider.dart';
import '../../controller/services/post/post_provider.dart';
import '../../models/ReelPostModel.dart';

class ReelScreen extends StatefulWidget {
  //final List<ReelPostModel> reels;
  final int initialIndex; // The index to start from
  final bool showEditDeleteOptions;
  final String? reelId;
  final bool? isNotificationReel;
  String? commentHightlightId;
  String? replyHighlightId;
  final bool isUserScreen;
  final String? commentCount;

   ReelScreen({
    Key? key,
    // required this.reels,
    this.initialIndex = 0,
    this.showEditDeleteOptions = true,
    this.reelId,
    this.isNotificationReel,
    this.commentHightlightId,
    this.replyHighlightId,
    required this.isUserScreen,
    this.commentCount,
  }) : super(key: key);

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  // bool isLiked = false;
  List<ReelPostModel> _reels = [];
  int limit = 10;
  int offset = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _fetchReels();

    if (widget.reelId != null) {
      final index = getReelIndexById(widget.reelId!, _reels);
      //debugger();
      if (index != -1) {
        _currentIndex = index;
      }
    }
    _pageController = PageController(initialPage: _currentIndex);

    if (widget.isNotificationReel == true && widget.reelId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () {
          showComments(widget.reelId!,true,context,'',commentCount: int.parse(widget?.commentCount??'0'));
        });
      });
    }
  }

  int getReelIndexById(String reelId, List<ReelPostModel> reels) {
    return reels.indexWhere((reel) => reel.id == reelId);
  }

  void _fetchReels() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserProfile? userProfile = await UserPreferences().getCurrentUser();
      int? userId = userProfile!.id;
      // UserProfile? currentUserID; 
      // userProfile.then((value){
      //   currentUserID=value!;
      // });
      if (userId == null) {
        print("Error: User ID is null. Please check the preferences.");
        // Optionally, navigate the user to the login screen here.
        return;
      }
    
     // print("User REEL SCRREN: $userId");

      // List<ReelPostModel> fetchedReels =
      //     await Provider.of<PostProvider>(context, listen: false)
      //         .fetchReels(context, userId, limit, offset);
      if(widget.isUserScreen){
        List<ReelPostModel> fetchedReels =
           await Provider.of<PostProvider>(context, listen: false)
               .fetchReels(context, userId.toString(), limit, offset);
               setState(() {
        _reels.addAll(fetchedReels);
        offset += limit;
        if (fetchedReels.length < limit) _hasMore = false;
      });
      }
      else{
      List<ReelPostModel> fetchedReels = await Provider.of<PostProvider>(context, listen: false)
          .fetchFollowersReels(context,userId);
          setState(() {
        _reels.addAll(fetchedReels);
        offset += limit;
        if (fetchedReels.length < limit) _hasMore = false;
      });

      }
        
      
    } catch (e) {
      print("Error fetching reels: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> deleteReel() async {
    // Call deletePost from the provider
    await Provider.of<PostProvider>(context, listen: false)
        .deletePost(_reels[_currentIndex].id.toString(), context, true);

    // Update the reel list and current index
    setState(() {
      _reels.removeAt(_currentIndex);

      if (_currentIndex >= _reels.length) {
        _currentIndex = _reels.isEmpty ? 0 : _reels.length - 1;
      }
    });

    // Navigate to the next reel if available
    if (_reels.isNotEmpty) {
      _pageController.jumpToPage(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.black,
          iconTheme: IconThemeData(color: AppColors.white),
        ),
        body: Consumer<PostProvider>(builder: (context, postProvider, child) {
          final reels = postProvider.reels;
          return _reels.isEmpty
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
                      itemCount: reels?.length,
                      scrollDirection: Axis.vertical,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        //debugger();
                        //print("RELL URL : ${reels![index].file}");
                        return ReelPost(
                          src: reels![index].file,
                        );
                      },
                    ),
                    Positioned(
                        right: 20,
                        bottom: 80,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (!reels[_currentIndex].isLiked) {
                                  await postProvider.reelLike(
                                    reels![_currentIndex].id,
                                    context,
                                    _currentIndex,
                                  );
                                } else {
                                  await postProvider.reelDisLike(
                                    reels![_currentIndex].id,
                                    context,
                                    _currentIndex,
                                  );
                                }
                              },
                              child: Icon(
                                reels![_currentIndex].isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: reels![_currentIndex].isLiked
                                    ? Colors.red
                                    : AppColors.white,
                                size: 30,
                              ),
                            ),
                            Text(
                              reels[_currentIndex].likesCount.toString(),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                //                debugger();
                                showComments(
                                    _reels[_currentIndex].id.toString(),true,context,widget.commentHightlightId.toString(),replyID: widget.replyHighlightId, commentCount:  _reels[_currentIndex].commentsCount);
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
                                      SnackBar(
                                          content: Text(
                                              'Edit functionality not implemented.')),
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
                        )),
                  ],
                );
        }));
  }
}
