import 'dart:async';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/controller/store/search/search_store.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/models/UserProfile/userstatus.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/messaging/chat_screen.dart';
import 'package:mobile/screens/profile/widgets/PostGrid.dart';
import 'package:mobile/screens/profile/widgets/PostWidget.dart';
import 'package:mobile/screens/search/widget/search_screen.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/story/create_story.dart';
import 'package:mobile/screens/story/create_story_screen.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
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
  List<PostModel> _posts = []; // List to hold all loaded posts
  List<Stories> _stories = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    // Fetch user status on initialization
    mediaProvider.fetchUserStatuses(limit: 10, offset: _offset);
    mediaProvider.fetchFollowerStories(context, limit: 10, offset: _offset);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPosts();
    });
  }

  void _fetchMoreStatuses() async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    setState(() {
      _isLoadingMore = true;
    });

    // Fetch next batch of statuses (e.g., 10 more)
    await mediaProvider.fetchUserStatuses(limit: 10, offset: _offset);

    setState(() {
      _stories.addAll(mediaProvider.statuses); // Add new statuses to the list
      _offset += 10; // Increment the offset for the next request
      _isLoadingMore = false;
    });
  }

  void _fetchPosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    setState(() {
      _isLoadingMore = true;
    });

    // Fetch posts directly from the provider
    await postProvider.fetchFollowerPost(context, limit: 10, offset: _offset);

    // Fetch posts from the provider after the fetch operation
    setState(() {
      _posts.addAll(postProvider.posts!); // Add posts from provider to _posts
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<MediaProvider>(
            builder: (context, mediaProvider, child) {
              final stories = mediaProvider.statuses ??
                  mediaProvider.followersStatus?.stories;

              // Define profileImageUrl to be accessible in both the if and else blocks
              final profileImageUrl = (stories != null &&
                      stories.isNotEmpty &&
                      stories.first.user?.profileImage != null)
                  ? '${ApiURLs.baseUrl2}${stories.first.user!.profileImage}'
                  : AppUtils.userImage; // Fallback URL for profile image

              if (stories != null && stories.isNotEmpty) {
                final List<Object?> allMediaFiles = stories.expand((story) {
                  return story.media!
                      .map((media) => media.file)
                      .whereType<String>();
                }).toList();
                print("USerStories :${allMediaFiles}");
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatusView(
                          statuses: allMediaFiles,
                          initialIndex: 0,
                          isVideo: false,
                          viewers: [],
                          userProfile: widget.userProfile,
                          token: widget.token!,
                          isUser: true,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                );
              } else {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => StoryScreen(
                          userProfile: widget.userProfile,
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                );
              }
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Theme(
            data: Theme.of(context).copyWith(
              tabBarTheme: TabBarTheme(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(child: Text('Content')),
                Tab(child: Text('Disclosure')),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.message_outlined, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoDialogRoute(
                      builder: (_) => ChatScreen(
                            userProfile: widget.userProfile!,
                          ),
                      context: context));
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
          ),
        ],
      ),
      drawer: const SideBar(),
      backgroundColor: AppColors.mainBgColor,
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(), // Disable TabBarView scrolling
        children: [
          ValueListenableBuilder<String?>(
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
                      children: [
                        // Integrate the horizontally scrollable story section
                        Container(
                          height: 120, // Adjust height as needed
                          child:
                              _buildStorySection(), // Calls the horizontal ListView
                        ),
                        const Divider(thickness: 1),
                        _posts.isEmpty
                            ? Center(
                                child: Text(
                                  "No Post Available Right Now",
                                  style: AppTextStyles.poppinsBold(),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Consumer<PostProvider>(
                                    builder: (context, postProvider, child) {
                                  return ListView.builder(
                                    itemCount: _posts!.length,
                                    shrinkWrap:
                                        true, // Prevents unbounded height
                                    physics:
                                        NeverScrollableScrollPhysics(), // Disable scrolling to avoid conflict
                                    itemBuilder: (context, index) {
                                      final post = _posts[index];
                                      return _buildPostCard(post, () {
                                        Navigator.push(
                                            context,
                                            CupertinoDialogRoute(
                                                builder: (_) => SinglePost(
                                                    postId: post.id.toString(),
                                                    onPostUpdated: () =>
                                                        _fetchPosts()),
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
          Center(child: Text('Disclosure Content Goes Here')),
        ],
      ),
    );
  }

  // Widget _buildStoriesSection() {
  //   final mediaProvider = Provider.of<MediaProvider>(context);
  //   final stories = mediaProvider.followersStatus?.stories ??
  //       mediaProvider.statuses;

  //   if (stories == null || stories.isEmpty) {
  //     return Center(child: Text('No stories available'));
  //   }

  //   // Log each story's details to ensure unique users and their media are correctly structured
  //   print('Total followers with stories: ${stories.length}');
  //   for (var story in stories) {
  //     print(
  //         'Username: ${story.user?.username}, Media Count: ${story.media?.length}');
  //   }

  //   return SizedBox(
  //     height: 80,
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: List.generate(stories.length, (followerIndex) {
  //           final story = stories[followerIndex];

  //           // Skip if no media
  //           if (story.media == null || story.media!.isEmpty) return SizedBox();

  //           // Extract only the current follower's media URLs
  //           final List<String> followerStatuses = story.media!
  //               .map((media) => '${ApiURLs.baseUrl2}${media.file}')
  //               .toList();

  //           // Use the first media file as the thumbnail for the story
  //           final firstMediaFile = story.media!.first.file;
  //           final username = story.user?.username ?? 'Unknown';

  //           return Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               InkWell(
  //                 onTap: () {
  //                   // Debug output on tap
  //                   print('Tapped on follower: $username');
  //                   print(
  //                       'Statuses for this follower: ${followerStatuses.length} items');

  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => FollowerStatusView(
  //                         followersStatuses: [
  //                           followerStatuses
  //                         ], // Pass only current follower's statuses
  //                         initialFollowerIndex: 0,
  //                         initialStatusIndex: 0,
  //                         userProfile: widget.userProfile,
  //                         token: widget.token!,
  //                       ),
  //                     ),
  //                   );
  //                 },
  //                 child: CircleAvatar(
  //                   backgroundColor: Colors.transparent,
  //                   radius: 20,
  //                   child: ClipOval(
  //                     child: firstMediaFile != null
  //                         ? Image.network(
  //                             '${ApiURLs.baseUrl2}$firstMediaFile',
  //                             fit: BoxFit.cover,
  //                             width: 40,
  //                             height: 40,
  //                             loadingBuilder:
  //                                 (context, child, loadingProgress) {
  //                               if (loadingProgress == null) return child;
  //                               return CircularProgressIndicator(
  //                                   color: AppColors.blue, strokeWidth: 6);
  //                             },
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return CircularProgressIndicator(
  //                                 color: AppColors.blue,
  //                                 strokeWidth: 6,
  //                               );
  //                             },
  //                           )
  //                         : CircularProgressIndicator(strokeWidth: 6),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 5),
  //               Text(username, style: const TextStyle(fontSize: 10)),
  //             ],
  //           );
  //         }),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStorySection() {
    int offset = 0; // Initialize offset
    return Consumer<MediaProvider>(
      builder: (context, statusProvider, child) {
        final users =
            statusProvider.stories.map((story) => story.user).toList();

        if (users.isEmpty && statusProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (users.isEmpty) {
          return Center(child: Text('No users available.'));
        }

        return SizedBox(
          height: 100,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!statusProvider.isLoading &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                // Fetch next set of users when reaching the end

                statusProvider.fetchFollowerStories(context,
                    limit: 10, offset: offset);
              }
              return true;
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: users.length + (statusProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == users.length) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final user = users[index];
                //   debugger();
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                  isVideo: false, // Assume default as false
                                  userProfile: widget.userProfile,
                                  isUser: false,
                                  token: widget!.token.toString(),
                                  viewers: [],
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 20,
                            child: ClipOval(
                              child: Image.network(
                                "${user?.profileImage != null ? user!.profileImage : AppUtils.userImage}",
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return CircularProgressIndicator(
                                      color: AppColors.blue, strokeWidth: 6);
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person, size: 60);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.username.toString() ?? 'Unknown',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(PostModel post, onPressed) {
    log('Hello $_currentIndexMap');
    List<String> fullMediaUrls = post.media.map((media) {
      print(media);
      final file = media.file;
      return file;
    }).toList();

    return PostWidget(
      postId: post.id.toString(),
      username: post.user.username,
      location: 'Location',
      date: post.createdAt,
      caption: '',
      mediaUrls: fullMediaUrls,
      profileImageUrl: post.user.profileImage != null
          ? "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.user.profileImage}"
          : AppUtils.userImage,
      isVideo:
          post.media.any((media) => media.mediaType == 'video') ? true : false,
      likes: post.likesCount.toString(),
      comments: post.commentsCount.toString(),
      shares: "50",
      saved: "50",
      refresh: () {},
      showCommentSection: false,
      isInteractive: true,
      isUserPost: false,
      onPressed: onPressed,
      onPressLiked: () async {
        final postProvider = Provider.of<PostProvider>(context, listen: false);

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
      isLiked: post.isLiked, postModel: post, // Use the post's `isLiked` value
    );
  }
}

class StatusView extends StatefulWidget {
  final List<Object?> statuses;
  final int initialIndex;
  final bool isVideo;
  final Duration statusDuration;
  final List<String> viewers;
  final UserProfile? userProfile;
  final String token;
  final bool isUser;

  StatusView({
    Key? key,
    required this.statuses,
    required this.initialIndex,
    required this.isVideo,
    this.statusDuration = const Duration(seconds: 5),
    this.viewers = const [],
    required this.userProfile,
    required this.token,
    required this.isUser,
  }) : super(key: key);

  @override
  _StatusViewState createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _offset = 0; // Tracks the current offset for pagination
  final int _limit = 10; // Limit per fetch
  Timer? _timer;
  late AnimationController _animationController;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _hasMore = true; // Flag to check if more statuses need to be loaded

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 15));
    _initializeStatus();
    _loadStatuses(); // Initial status fetch
  }

  // Method to load statuses with pagination
  void _loadStatuses() {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    mediaProvider.fetchUserStatuses(limit: _limit, offset: _offset).then((_) {
      setState(() {
        _isLoading = false;
        _hasMore = mediaProvider.hasMore;
      });
    });
  }

  void _initializeStatus() {
    _animationController.stop();
    _timer?.cancel();
    setState(() => _isLoading = true);

    if (widget.isVideo) {
      _initializeVideo();
    } else {
      _initializeImage();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(
        '${ApiURLs.baseUrl2}${widget.statuses[_currentIndex]}');

    _videoController!.addListener(() {
      if (_videoController!.value.isBuffering) {
        setState(() {
          _isLoading = true;
        });
      } else if (_videoController!.value.isInitialized) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    try {
      await _videoController!.initialize();
      final videoDuration = _videoController!.value.duration;
      final cappedDuration = videoDuration <= Duration(seconds: 10)
          ? videoDuration
          : Duration(seconds: 10);

      _animationController.duration = cappedDuration;
      _videoController!.play();
      _animationController.forward(from: 0);
      _timer = Timer(cappedDuration, _onNextStatus);
    } catch (e) {
      print("Error loading video: $e");
      setState(() => _isLoading = false);
    }
  }

  void _initializeImage() {
    _animationController.stop();
    _timer?.cancel();

    setState(() => _isLoading = true);

    Image.network(
      '${ApiURLs.baseUrl2}${widget.statuses[_currentIndex]}',
      fit: BoxFit.cover,
    ).image.resolve(ImageConfiguration()).addListener(
          ImageStreamListener(
            (ImageInfo info, bool _) {
              setState(() {
                _isLoading = false;
                _animationController.duration = Duration(seconds: 10);
                _animationController.forward(from: 0);
              });
              _timer = Timer(Duration(seconds: 10), _onNextStatus);
            },
            onError: (error, stackTrace) {
              print("Error loading image: $error");
              setState(() => _isLoading = false);
            },
          ),
        );
  }

  void _onNextStatus() {
    _animationController.stop();
    _timer?.cancel();

    if (_currentIndex < widget.statuses.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _initializeStatus();
    } else if (_hasMore) {
      // Load next batch of statuses when the current batch ends
      setState(() {
        _offset += _limit;
        _isLoading = true;
      });
      _loadStatuses(); // Fetch next batch
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : widget.isVideo &&
                          _videoController != null &&
                          _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : Image.network(
                          '${ApiURLs.baseUrl2}${widget.statuses[_currentIndex]}',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.error, color: Colors.white),
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
            ),
            GestureDetector(
              onTapUp: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < screenWidth / 2) {
                  if (_currentIndex > 0) _onPreviousStatus();
                } else {
                  if (_currentIndex < widget.statuses.length - 1) {
                    _onNextStatus();
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              },
              onLongPressStart: (_) {
                _animationController.stop();
                _timer?.cancel();
                _videoController?.pause();
              },
              onLongPressEnd: (_) {
                _animationController.forward();
                _timer = Timer(
                    _animationController.duration! *
                        (1.0 - _animationController.value),
                    _onNextStatus);
                _videoController?.play();
              },
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(
                  widget.statuses.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Stack(
                        children: [
                          Container(
                            height: 3,
                            color: Colors.grey.shade400,
                          ),
                          index == _currentIndex
                              ? AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Container(
                                      height: 3,
                                      width: MediaQuery.of(context).size.width *
                                          _animationController.value,
                                      color: Colors.white,
                                    );
                                  },
                                )
                              : Container(
                                  height: 3,
                                  color: index < _currentIndex
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            widget.isUser
                ? Positioned(
                    bottom: 40,
                    child: GestureDetector(
                      onTap: _showViewers,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_red_eye, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            '${widget.viewers.length}',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    CupertinoDialogRoute(
                                        builder: (_) => StoryScreen(
                                              userProfile: widget.userProfile,
                                              token: widget.token,
                                            ),
                                        context: context));
                              },
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 27,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _onPreviousStatus() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _initializeStatus();
    }
  }

  void _showViewers() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Viewers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.viewers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(widget.viewers[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
