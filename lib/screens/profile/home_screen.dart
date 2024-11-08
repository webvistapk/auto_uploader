import 'dart:async';

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
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/story/create_story.dart';
import 'package:mobile/screens/story/create_story_screen.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../controller/services/StatusProvider.dart';

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
              final stories = mediaProvider.userStatus?.stories ?? mediaProvider.followersStatus?.stories;

              if (stories != null && stories.isNotEmpty) {
                // Collect all media files from all stories, ensuring it's a List<String>
                final List<Object?> allMediaFiles = stories.expand((story) {
                  // Map each media file to String, filter out nulls, and ensure List<String>
                  return story.media?.map((media) => media.file).whereType<String>() ?? [];
                }).toList();

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatusView(
                          statuses: allMediaFiles, // Pass all media files in sequence
                          initialIndex: 0,
                          isVideo: false, // Adjust based on your video handling logic
                          viewers: [],
                          userProfile: widget.userProfile,
                          token: widget.token!,
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
            onPressed: () {},
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
              if (searchQuery == null || searchQuery.isEmpty) {
                return ListView(
                  children: [
                    Center(child: _buildStoriesSection()),
                    const Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _buildPostCard(),
                          _buildPostCard(),
                        ],
                      ),
                    )
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
    final stories = mediaProvider.followersStatus?.stories ?? mediaProvider.userStatus?.stories;

    if (stories == null || stories.isEmpty) {
      return Center(
        child: Text('No stories available'),
      );
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
            final mediaFile = story.media!.first.file;
            final isVideo = story.media!.first.mediaType == 'video';
            final username = story.user?.username ?? 'Unknown';

            // Collect all media files from this story, ensuring no null values
            final List<String> storyMediaFiles = story.media!
                .map((media) => media.file)
                .where((file) => file != null)
                .cast<String>()
                .toList();

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatusView(
                      statuses: storyMediaFiles,  // Pass media files from this story
                      initialIndex: 0,
                      isVideo: isVideo,
                      viewers: [],
                      userProfile: widget.userProfile,
                      token: widget.token!,
                    ),
                  ),
                );
              },
              child: _buildStoryAvatar(username, mediaFile, isVideo),
            );
          }).toList(),
        ),
      ),
    );
  }



  Widget _buildStoryAvatar(String username, String? mediaFile, bool isVideo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatusView(
                    statuses: [
                      mediaFile ?? 'assets/logo.webp'
                    ], // Use a default value if mediaFile is null
                    initialIndex: 0,
                    isVideo: isVideo,
                    viewers: [], userProfile: widget.userProfile,
                    token: widget.token!,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: mediaFile != null
                  ? isVideo
                      ? AssetImage('assets/video_placeholder.png')
                          as ImageProvider // Video placeholder
                      : NetworkImage(
                          '${ApiURLs.baseUrl2}$mediaFile') // Image URL
                  : AssetImage(
                      'assets/logo.webp'), // Default placeholder if mediaFile is null
            ),
          ),
          const SizedBox(height: 5),
          Text(username, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading image
              CircleAvatar(
                backgroundImage: AssetImage('assets/tellus.webp'),
                radius: 20, // Adjust size if needed
              ),
              const SizedBox(
                  width: 10), // Add some space between the image and text
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'username1',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Location',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Trailing button
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
            Container(
              width: double.infinity,
              height: 350,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/tellus.webp'),
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
            children: const [
              Text("Kashif", style: TextStyle(fontSize: 12)),
              Text(
                  "datawarning: The value of the local variable 'size' isn't used.",
                  style: TextStyle(fontSize: 10)),
              Text("17-Aug-2024", style: TextStyle(fontSize: 8)),
            ],
          ),
        ),
      ],
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

  StatusView({
    Key? key,
    required this.statuses,
    required this.initialIndex,
    required this.isVideo,
    this.statusDuration = const Duration(seconds: 5),
    this.viewers = const [],
    required this.userProfile,
    required this.token,
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
            Positioned(
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
            ),
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
