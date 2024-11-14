import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/controller/store/search/search_store.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch user status on initialization
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    final storyService = StoryService(mediaProvider);
    storyService.getUserStatus();
    storyService.getFollowersStatus();

    // Initial fetch for posts with pagination
    _fetchPosts();
  }

  void _fetchPosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    setState(() {
      _isLoadingMore = true;
    });
    List<PostModel> newPosts = await postProvider.fetchFollowerPost(context,
        limit: 10, offset: _offset);
    setState(() {
      _posts.addAll(newPosts); // Append new posts to the existing list
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
              final stories = mediaProvider.userStatus?.stories ??
                  mediaProvider.followersStatus?.stories;
              if (stories != null && stories.isNotEmpty) {
                final List<Object?> allMediaFiles = stories.expand((story) {
                  return story.media!
                      .map((media) => media.file)
                      .whereType<String>();
                }).toList();

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
                    child: ClipOval(
                      child: Image.network(
                        '${ApiURLs.baseUrl2}${stories.first.media?.first.file ?? 'assets/logo.webp'}',
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    ),
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
                    backgroundImage: AssetImage('assets/logo.webp'),
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
            icon: Icon(Icons.notifications, color: Colors.grey),
            onPressed: () {},
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
                  child: ListView(
                    children: [
                      Center(child: _buildStoriesSection()),
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
                        child: Column(
                          children: _posts
                              .map((post) => _buildPostCard(post))
                              .toList(),
                        ),
                      ),Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: _posts
                              .map((post) => _buildPostCard(post))
                              .toList(),
                        ),
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

  Widget _buildStoriesSection() {
    final mediaProvider = Provider.of<MediaProvider>(context);
    final stories = mediaProvider.followersStatus?.stories ?? mediaProvider.userStatus?.stories;

    if (stories == null || stories.isEmpty) {
      return Center(child: Text('No stories available'));
    }

    // Log each story's details to ensure unique users and their media are correctly structured
    print('Total followers with stories: ${stories.length}');
    for (var story in stories) {
      print('Username: ${story.user?.username}, Media Count: ${story.media?.length}');
    }

    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(stories.length, (followerIndex) {
            final story = stories[followerIndex];

            // Skip if no media
            if (story.media == null || story.media!.isEmpty) return SizedBox();

            // Extract only the current follower's media URLs
            final List<String> followerStatuses = story.media!
                .map((media) => '${ApiURLs.baseUrl2}${media.file}')
                .toList();

            // Use the first media file as the thumbnail for the story
            final firstMediaFile = story.media!.first.file;
            final username = story.user?.username ?? 'Unknown';

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    // Debug output on tap
                    print('Tapped on follower: $username');
                    print('Statuses for this follower: ${followerStatuses.length} items');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FollowerStatusView(
                          followersStatuses: [followerStatuses], // Pass only current follower's statuses
                          initialFollowerIndex: 0,
                          initialStatusIndex: 0,
                          userProfile: widget.userProfile,
                          token: widget.token!,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 20,
                    child: ClipOval(
                      child: firstMediaFile != null
                          ? Image.network(
                        '${ApiURLs.baseUrl2}$firstMediaFile',
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return CircularProgressIndicator(
                              color: AppColors.blue, strokeWidth: 6);
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return CircularProgressIndicator(
                            color: AppColors.blue,
                            strokeWidth: 6,
                          );
                        },
                      )
                          : CircularProgressIndicator(strokeWidth: 6),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(username, style: const TextStyle(fontSize: 10)),
              ],
            );
          }),
        ),
      ),
    );
  }



  Widget _buildPostCard(PostModel post) {
    _currentIndexMap[post.id] ??= 0;
    List<String> fullMediaUrls = post.media.map((media) {
      final file = media.file;
      return file.startsWith('http') ? file : '${ApiURLs.baseUrl2}$file';
    }).toList();

    return PostWidget(
      postId: post.id.toString(),
      username: post.user.username,
      location: 'Location',
      date: post.createdAt,
      caption: '',
      mediaUrls: fullMediaUrls,
      profileImageUrl: AppUtils.testImage,
      isVideo: post.media.any((media) => media.mediaType == 'video'),
      likes: post.likesCount.toString(),
      comments: post.commentsCount.toString(),
      shares: "50",
      saved: "50",
      refresh: () {},
      showFollowButton: true,
      isInteractive: true,
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
  Timer? _timer;
  late AnimationController _animationController;
  VideoPlayerController? _videoController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 15));
    _initializeStatus();
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
//Follower Status
class FollowerStatusView extends StatefulWidget {
  final List<List<String>> followersStatuses; // List of statuses per follower
  final int initialFollowerIndex; // Start with a specific follower's statuses
  final int initialStatusIndex; // Start at a specific status within that follower
  final UserProfile? userProfile;
  final String token;

  FollowerStatusView({
    Key? key,
    required this.followersStatuses,
    this.initialFollowerIndex = 0,
    this.initialStatusIndex = 0,
    required this.userProfile,
    required this.token,
  }) : super(key: key);

  @override
  _FollowerStatusViewState createState() => _FollowerStatusViewState();
}

class _FollowerStatusViewState extends State<FollowerStatusView> with TickerProviderStateMixin {
  late int _currentFollowerIndex;
  late int _currentStatusIndex;
  Timer? _timer;
  bool _isLoading = true;
  late AnimationController _animationController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _currentFollowerIndex = widget.initialFollowerIndex;
    _currentStatusIndex = widget.initialStatusIndex;
    AnimationController(vsync: this, duration: Duration(seconds: 15));
    _initializeStatus();
  }

  void _initializeStatus() {
    _animationController.stop();
    _timer?.cancel();
    setState(() => _isLoading = true);

    if (_isVideo(widget.followersStatuses[_currentFollowerIndex][_currentStatusIndex])) {
      _initializeVideo();
    } else {
      _initializeImage();
    }
  }

  bool _isVideo(String url) {
    return url.endsWith(".mp4") || url.endsWith(".mov"); // Simple check for video files
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(
      widget.followersStatuses[_currentFollowerIndex][_currentStatusIndex],
    );

    _videoController!.addListener(() {
      if (_videoController!.value.isBuffering) {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }
      } else if (_videoController!.value.isInitialized) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });

    try {
      await _videoController!.initialize();
      final videoDuration = _videoController!.value.duration;
      final cappedDuration = videoDuration <= Duration(seconds: 10)
          ? videoDuration : Duration(seconds: 10);

      if (mounted) {
        setState(() {
          _animationController.duration = cappedDuration;
        });
        _videoController!.play();
        _animationController.forward(from: 0);
        _timer = Timer(cappedDuration, _onNextStatus);
      }
    } catch (e) {
      print("Error loading video: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _initializeImage() {
    _animationController.stop();
    _timer?.cancel();
    if (mounted) {
      setState(() => _isLoading = true);
    }

    Image.network(
      widget.followersStatuses[_currentFollowerIndex][_currentStatusIndex],
      fit: BoxFit.cover,
    ).image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo info, bool _) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _animationController.duration = Duration(seconds: 10);
              _animationController.forward(from: 0);
            });
            _timer = Timer(Duration(seconds: 10), _onNextStatus);
          }
        },
        onError: (error, stackTrace) {
          print("Error loading image: $error");
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      ),
    );
  }

  void _onNextStatus() {
    _animationController.stop();
    _timer?.cancel();

    if (_currentStatusIndex < widget.followersStatuses[_currentFollowerIndex].length - 1) {
      setState(() {
        _currentStatusIndex++;
      });
      _initializeStatus();
    } else if (_currentFollowerIndex < widget.followersStatuses.length - 1) {
      setState(() {
        _currentFollowerIndex++;
        _currentStatusIndex = 0;
      });
      _initializeStatus();
    } else {
      Navigator.of(context).pop(); // End of all followers' statuses
    }
  }

  void _onPreviousStatus() {
    if (_currentStatusIndex > 0) {
      setState(() {
        _currentStatusIndex--;
      });
      _initializeStatus();
    } else if (_currentFollowerIndex > 0) {
      setState(() {
        _currentFollowerIndex--;
        _currentStatusIndex = widget.followersStatuses[_currentFollowerIndex].length - 1;
      });
      _initializeStatus();
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
          children: [
            Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : _isVideo(widget.followersStatuses[_currentFollowerIndex][_currentStatusIndex]) &&
                  _videoController != null &&
                  _videoController!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
                  : Image.network(
                widget.followersStatuses[_currentFollowerIndex][_currentStatusIndex],
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
                  _onPreviousStatus();
                } else {
                  _onNextStatus();
                }
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
                  widget.followersStatuses[_currentFollowerIndex].length,
                      (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Stack(
                        children: [
                          Container(
                            height: 3,
                            color: Colors.grey.shade400,
                          ),
                          index == _currentStatusIndex
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
                            color: index < _currentStatusIndex ? Colors.white : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


