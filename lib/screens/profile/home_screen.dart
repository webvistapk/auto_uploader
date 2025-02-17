import 'dart:async';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/controller/services/post/comment_provider.dart';
import 'package:mobile/controller/store/search/search_store.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/models/UserProfile/userstatus.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/messaging/chat_screen.dart';
import 'package:mobile/screens/notification/notificationScreen.dart';
import 'package:mobile/screens/profile/FollowerReelScreen.dart';
import 'package:mobile/screens/profile/widgets/DiscoursePost.dart';
import 'package:mobile/screens/profile/widgets/DiscourseScreenWidget.dart';
import 'package:mobile/screens/profile/widgets/PostGrid.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:mobile/screens/search/widget/search_screen.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/story/create_story.dart';
import 'package:mobile/screens/story/create_story_screen.dart';
import 'package:mobile/screens/story/widget/status_view_screen.dart';
import 'package:mobile/screens/story/widget/users_story_screen.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../common/app_text_styles.dart';
import '../../common/utils.dart';
import '../../controller/services/StatusProvider.dart';
import '../../controller/services/post/post_provider.dart';
import '../../models/UserProfile/post_model.dart';
import 'SinglePost.dart';
import 'package:mobile/screens/profile/widgets/PostGrid.dart' as postGrid;
import 'package:mobile/screens/profile/widgets/PostWidget.dart' as postWidget;
import 'package:mobile/models/UserProfile/userstatus.dart' as userStatusModel;

class HomeScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final String? token;

  const HomeScreen({super.key, this.userProfile, this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Map<int, int> _currentIndexMap = {};
  int _offset = 0; // Pagination offset
  bool _isLoadingMore = false; // Indicator for loading more posts
  int selectedIndex = 0; // 0: Content, 1: Discourse, 2: Reels
  List<Stories> _stories = [];
  final PageController _pageController = PageController();

  void onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<PostProvider>();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaProvider = context.read<MediaProvider>();
      // Fetch user status on initialization
      initFunctions(mediaProvider);
    });
  }

  initFunctions(MediaProvider mediaProvider) {
    mediaProvider.fetchUserStatuses(limit: 10, offset: _offset);
    mediaProvider.fetchFollowerStories(context, limit: 10, offset: _offset);
    _fetchPosts();
  }

  void _fetchMoreStatuses() async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    if (mounted)
      setState(() {
        _isLoadingMore = true;
      });

    // Fetch next batch of statuses (e.g., 10 more)
    await mediaProvider.fetchUserStatuses(limit: 10, offset: _offset);
    if (mounted)
      setState(() {
        _stories.addAll(mediaProvider.statuses); // Add new statuses to the list
        _offset += 10; // Increment the offset for the next request
        _isLoadingMore = false;
      });
    print("OFFSET :${_offset}");
  }

  void _fetchPosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    if (mounted)
      setState(() {
        _isLoadingMore = true;
      });

    // Fetch posts directly from the provider
    await postProvider.fetchFollowerPost(context, limit: 10, offset: _offset);

    // Fetch posts from the provider after the fetch operation
    if (mounted)
      setState(() {
        // postProvider.posts.(postProvider.posts!); // Add posts from provider to _posts
        _offset += 10;
        _isLoadingMore = false;
      });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedIndex == 2
          ? null
          : AppBar(
              backgroundColor: Color(0xffF4F6F6), // Set fixed color
              elevation: 0,
              toolbarHeight: 60,
              leading: Padding(
                padding: const EdgeInsets.all(15),
                child: Image.asset(
                  AppIcons.calender,
                  width: 42.sp,
                ),
              ),
              actions: [
                IconButton(
                  icon: Image.asset(
                    AppIcons.bell,
                    color: AppColors.black,
                    width: 42.sp,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoDialogRoute(
                            builder: (_) => NotificationScreen(),
                            context: context));
                  },
                ),
                // IconButton(
                //   icon: Icon(Icons.search, color: Colors.grey),
                //   onPressed: () {
                //     showSearch(context: context, delegate: CustomSearchDelegate());
                //   },
                // ),
              ],
            ),
      drawer: const SideBar(),
      backgroundColor: Color(0xffF4F6F6),
      body: Stack(
        children: [
          // Show Fullscreen Reels if selected

          // Tab Buttons (Always on top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0),

                color: selectedIndex == 2
                    ? Colors.transparent
                    : Color(0xffF4F6F6), // Make it overlay
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton("Content", 0),
                      SizedBox(
                        width: 118.sp,
                      ),
                      _buildTabButton("Discourse", 1),
                      SizedBox(
                        width: 118.sp,
                      ),
                      _buildTabButton("Reels", 2),
                    ],
                  ),

                  if (selectedIndex != 2)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Divider(color: Colors.black, thickness: 1),
                        Positioned(
                          left: selectedIndex == 0
                              ? MediaQuery.of(context).size.width * 0.20
                              : selectedIndex == 1
                                  ? MediaQuery.of(context).size.width * 0.46
                                  : MediaQuery.of(context).size.width * 0.78,
                          child: Container(
                            width: 107.sp, // Width of the line
                            height: 2.2, // Thickness of the line
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  //  selectedIndex == 2 ? Container() : Divider()
                ]),
              ),
            ),
          ),

          // Show Normal Screens

          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: PageView(
              controller: _pageController,
              onPageChanged: onPageChanged,
              children: [
                _buildNormalScreen(0),
                _buildNormalScreen(1),
                _buildNormalScreen(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalScreen(int index) {
    switch (index) {
      case 0:
        return ContentScreen();
      case 1:
        return DiscourseScreen(userProfile: widget.userProfile);
      case 2:
        return SafeArea(child: FollowerReelScreen());
      default:
        return Container();
    }
  }

  Widget ContentScreen() {
    return Container(
      color: AppColors.white,
      child: ValueListenableBuilder<String?>(
        valueListenable: SearchStore.searchQuery,
        builder: (context, searchQuery, child) {
          if (searchQuery == null || searchQuery.isEmpty) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !_isLoadingMore) {
                  _fetchPosts();
                }
                return false;
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Integrate the horizontally scrollable story section

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UsersStoryScreen(
                          userProfile: widget.userProfile!,
                          token: widget.token!,
                        ),

                        // Spacer(),
                        //SizedBox(width: 10),
                        Flexible(child: Center(child: _followerStorySection())),
                        //Spacer(),
                      ],
                    ), // Calls the horizontal ListView

                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Consumer<PostProvider>(
                          builder: (context, postProvider, child) {
                        final posts = postProvider.posts ?? [];
                        return ListView.builder(
                          itemCount: posts.length,
                          shrinkWrap: true, // Prevents unbounded height
                          physics:
                              NeverScrollableScrollPhysics(), // Disable scrolling to avoid conflict
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return _buildPostCard(post, () {
                              Navigator.push(
                                  context,
                                  CupertinoDialogRoute(
                                      builder: (_) => SinglePost(
                                          postId: post.id.toString(),
                                          onPostUpdated: () {}),
                                      context: context));
                            });
                          },
                        );
                      }),
                    ),
                    if (_isLoadingMore)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          } else {
            return SearchWidget(
              query: searchQuery,
              authToken: Prefrences.getAuthToken().toString(),
            );
          }
        },
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
         _pageController.animateToPage(
    index,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontFamily: selectedIndex == index ? 'fontBold' : 'fontMedium',
            color: selectedIndex == 2
                ? Colors.white
                : selectedIndex == index
                    ? Colors.black
                    : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }

  Widget _followerStorySection() {
    int offset = 0; // Initialize offset
    return Consumer<MediaProvider>(
      builder: (context, statusProvider, child) {
        final users =
            statusProvider.stories.map((story) => story.user).toList();

        if (users.isEmpty && statusProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (users.isEmpty) {
          return Container(); // Return empty widget if no users
        }

        double dynamicPadding = 100.0 - (users.length - 1) * 21.0;
        dynamicPadding = dynamicPadding.clamp(20.0, 100.0);

        return Padding(
          padding: EdgeInsets.only(left: dynamicPadding),
          child: SizedBox(
            height: 60,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!statusProvider.isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  statusProvider.fetchFollowerStories(context,
                      limit: 10, offset: offset);
                  offset += 10; // Update offset
                }
                return true;
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length + (statusProvider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == users.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final user = users[index];

                  log("Users: $user");
                  print("IMage: ${user!.profileImage}");
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            final userMediaFiles = statusProvider.stories
                                .where((story) => story.user!.id == user!.id)
                                .expand((story) => story.media ?? [])
                                .map((media) => media.file)
                                .where((file) => file != null)
                                .cast<String>()
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StatusView(
                                  statuses: userMediaFiles,
                                  initialIndex: 0,
                                  // isVideo: false,
                                  userProfile: widget.userProfile,
                                  isUser: false,
                                  token: widget.token.toString(),
                                  viewers: [],
                                  statusId: [],
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              user!.profileImage != null
                                  ? ApiURLs.baseUrl.replaceAll("/api/", '') +
                                      user!.profileImage.toString()
                                  : AppUtils.userImage,
                            ),
                            onBackgroundImageError: (_, __) =>
                                const Icon(Icons.person, size: 45),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        Text(
                          user?.username ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 9.84.sp, color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(PostModel post, onPressed) {
    List<String> fullMediaUrls = post.media.map((media) {
      final file = media.file;
      return file;
    }).toList();

    return Container(
      padding: EdgeInsets.only(bottom: 8),
      child: PostWidget(
        postId: post.id.toString(),
        username: post.user.username,
        location: '',
        date: post.createdAt,
        caption: post.post,
        mediaUrls: fullMediaUrls,
        profileImageUrl: post.user.profileImage != null
            ? "${post.user.profileImage}"
            : AppUtils.userImage,
        isVideo: post.media.any((media) => media.mediaType == 'video')
            ? true
            : false,
        likes: post.likesCount.toString(),
        comments: post.commentsCount.toString(),
        shares: "",
        saved: "",
        refresh: () {},
        showCommentSection: false,
        isInteractive: true,
        isUserPost: widget.userProfile!.id == post.user.id ? true : false,
        onPressed: onPressed,
        onPressLiked: () async {
          final postProvider =
              Provider.of<PostProvider>(context, listen: false);

          if (post.isLiked == false) {
            // Like the post
            await postProvider.newLikes(
              post.id,
              context,
            );
          } else {
            // Dislike the post
            await postProvider.userDisLikes(
              post.id,
              context,
            );
          }
        },
        isLiked: post.isLiked, // Use the post's `isLiked`
        postModel: post,
        postTitle: post.postTitle,
        postDescription: post.postDescription,
        privacy: post.privacy,
      ),
    );
  }
}
