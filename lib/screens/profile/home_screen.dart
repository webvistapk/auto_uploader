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
import 'package:mobile/screens/search/widget/search_screen.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/story/create_story.dart';
import 'package:mobile/screens/story/create_story_screen.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../controller/services/StatusProvider.dart';
import '../../controller/services/post/post_provider.dart';
import '../../models/UserProfile/post_model.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch user status on initialization
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    final storyService = StoryService(mediaProvider);
    storyService.getUserStatus();
    storyService.getFollowersStatus();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.fetchFollowerPost(context);
  }

  Future<void> _loadImage(String url) async {
    try {
      await NetworkImage('${ApiURLs.baseUrl}$url').evict();
    } catch (e) {
      print("Error loading image: $e");
    }
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
              // Use user stories if available, otherwise fallback to follower stories
              final stories = mediaProvider.userStatus?.stories ??
                  mediaProvider.followersStatus?.stories;

              if (stories != null && stories.isNotEmpty) {
                // Collect all media files from all stories, ensuring it's a List<String>
                final List<Object?> allMediaFiles = stories.expand((story) {
                  // Map each media file to String, filter out nulls, and ensure List<String>
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
                          statuses:
                              allMediaFiles, // Pass all media files in sequence
                          initialIndex: 0,
                          isVideo:
                              false, // Adjust based on your video handling logic
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
                        '${ApiURLs.baseUrl2}${stories.first.media?.first.file ?? 'assets/logo.webp'}', // First story as thumbnail
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                );
              } else {
                // Default image if no stories are available
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.black,
          labelStyle: TextStyle(color: Colors.black),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Content'),
            Tab(text: 'Disclosure'),
          ],
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
          // Content Tab
          ValueListenableBuilder<String?>(
            valueListenable: SearchStore.searchQuery,
            builder: (context, searchQuery, child) {
              final postProvider = Provider.of<PostProvider>(context);

              if (searchQuery == null || searchQuery.isEmpty) {
                return ListView(
                  children: [
                    Center(child: _buildStoriesSection()),
                    const Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: postProvider.cachedPosts
                            .map((post) => _buildPostCard(post))
                            .toList(),
                      ),
                    ),
                  ],
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

    // Check if there are follower stories, otherwise fallback to user stories
    final stories = mediaProvider.followersStatus?.stories ??
        mediaProvider.userStatus?.stories;

    if (stories == null || stories.isEmpty) {
      return Center(
        child: Text('No stories available'),
      );
    }

    // Group stories by user ID
    final Map<int, List<String>> userStoriesMap = {};
    for (var story in stories) {
      if (story.media == null || story.media!.isEmpty) continue;
      final userId = story.user?.id?.toInt(); // Ensure userId is int
      if (userId != null) {
        if (userStoriesMap.containsKey(userId)) {
          userStoriesMap[userId]!.addAll(
            story.media!
                .map((media) => media.file)
                .where((file) => file != null)
                .map((file) => file as String)
                .toList(),
          );
        } else {
          userStoriesMap[userId] = story.media!
              .map((media) => media.file)
              .where((file) => file != null)
              .map((file) => file as String)
              .toList();
        }
      }
    }

    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: stories.map((story) {
            // Check if the story has media; if not, skip it
            if (story.media == null || story.media!.isEmpty) return SizedBox();

            // Get the first media file in the story as a thumbnail
            final firstMediaFile = story.media!.first.file;
            final List<String> storyMediaFiles = story.media!
                .map((media) => media.file)
                .where((file) => file != null)
                .cast<String>()
                .toList();

            // Access the username from the story's user property
            final username = story.user!.username;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatusView(
                          statuses:
                              storyMediaFiles, // Pass all media files for this user
                          initialIndex: 0,
                          isVideo:
                              false, // Adjust based on your video handling logic
                          viewers: [],
                          userProfile: widget.userProfile,
                          token: widget.token!,
                          isUser: false,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    child: ClipOval(
                      child: firstMediaFile != null
                          ? Image.network(
                              '${ApiURLs.baseUrl2}$firstMediaFile',
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            )
                          : Image.asset(
                              'assets/logo.webp', // Default placeholder if no media
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  story.user!.username.toString(), // Display the username here
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage("assets/tellus.webp"),
                /*NetworkImage('${ApiURLs.baseUrl2}${post.user.profileImageUrl}'),*/
                radius: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user.username,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Location', // Update if location data is available
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Follow',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            // Use CarouselSlider if there's more than one media item
            post.media.length > 1
                ? CarouselSlider.builder(
                    itemCount: post.media.length,
                    itemBuilder: (context, index, realIndex) {
                      final media = post.media[index];
                      final mediaUrl = '${ApiURLs.baseUrl2}${media.file}';
                      final isVideo = media.mediaType == 'video';

                      return isVideo
                          ? _buildVideoPlayer(mediaUrl)
                          : Image.network(
                              mediaUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                    },
                    options: CarouselOptions(
                      height: 350,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: false,
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 350,
                    decoration: BoxDecoration(
                      image:
                          post.media.isNotEmpty // Check if media is available
                              ? DecorationImage(
                                  image: NetworkImage(
                                      '${ApiURLs.baseUrl2}${post.media.first.file}'),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: AssetImage(
                                      'assets/logo.webp'), // Placeholder image
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Center(
                  child: Text("Text",
                      style: TextStyle(fontSize: 10, color: AppColors.white)),
                ),
              ),
              const Icon(Icons.more_horiz_outlined),
              Row(
                children: [
                  Column(
                    children: [
                      const Icon(FontAwesomeIcons.share, size: 20),
                      Text("0", style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      const Icon(CupertinoIcons.bookmark, size: 20),
                      Text("0", style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: const [
                      Icon(Icons.favorite_border, size: 20),
                      Text("100", style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: const [
                      Icon(CupertinoIcons.chat_bubble_fill, size: 20),
                      Text("100", style: TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.user.firstName, style: TextStyle(fontSize: 12)),
              Text(post.createdAt, style: TextStyle(fontSize: 8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaCarousel(List<dynamic> mediaList) {
    return CarouselSlider.builder(
      itemCount: mediaList.length,
      itemBuilder: (context, index, realIndex) {
        final media = mediaList[index];
        final isVideo = media['media_type'] == 'video';
        final mediaUrl = '${ApiURLs.baseUrl2}${media['file']}';

        return isVideo
            ? _buildVideoPlayer(mediaUrl)
            : Image.network(
                mediaUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              );
      },
      options: CarouselOptions(
        height: 200,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
        autoPlay: false,
      ),
    );
  }

  Widget _buildInteractionIcon(IconData icon, String count) {
    return Column(
      children: [
        Icon(icon, size: 20),
        Text(count, style: TextStyle(fontSize: 9)),
      ],
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 200,
        child: VideoPlayerWidget(videoUrl: videoUrl),
      ),
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
    _animationController = AnimationController(vsync: this);
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
      final cappedDuration = videoDuration <= Duration(seconds: 15)
          ? videoDuration
          : Duration(seconds: 15);

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
                _animationController.duration = Duration(seconds: 5);
                _animationController.forward(from: 0);
              });
              _timer = Timer(Duration(seconds: 5), _onNextStatus);
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
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
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
