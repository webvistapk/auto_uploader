import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/controller/store/search/search_store.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:mobile/screens/widgets/top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
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
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/tellus.webp'),
          ),
        ),
       /* title: Text('Home Screen', style: TextStyle(color: Colors.black)),*/
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.black,
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
                    // Stories Section
                    Center(child: _buildStoriesSection()),
                    const Divider(thickness: 1),
                    // Post Cards
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
          // Disclosure Tab
          Center(
            child: Text('Disclosure Content Goes Here'),
          ),
        ],
      ),
    );
  }


  Widget _buildStoriesSection() {
    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            _buildStoryAvatar('User1', 'assets/tellus.webp'),
            _buildStoryAvatar('User2', 'assets/tellus.webp'),
            _buildStoryAvatar('User3', 'assets/tellus.webp'),
            _buildStoryAvatar('User4', 'assets/tellus.webp'),
            _buildStoryAvatar('User4', 'assets/tellus.webp'),

          ],
        ),
      ),
    );
  }



  Widget _buildStoryAvatar(String username, String imagePath) {
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
                      'assets/tellus.webp',
                      'assets/tellus.webp',
                      // Add more statuses if you have more images or videos
                    ],
                    initialIndex: 0,
                    isVideo: false,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(imagePath),
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
              const SizedBox(width: 10), // Add some space between the image and text
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'username1',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                  child: Text("Text", style: TextStyle(fontSize: 10, color: AppColors.white)),
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
              Text("datawarning: The value of the local variable 'size' isn't used.", style: TextStyle(fontSize: 10)),
              Text("17-Aug-2024", style: TextStyle(fontSize: 8)),
            ],
          ),
        ),
      ],
    );
  }

}


class StatusView extends StatefulWidget {
  final List<String> statuses; // List of status images/videos
  final int initialIndex; // Initial index of the status to be shown
  final bool isVideo;
  final Duration statusDuration; // Duration for each status to show
  final List<String> viewers; // List of viewers' names

  StatusView({
    Key? key,
    required this.statuses,
    required this.initialIndex,
    required this.isVideo,
    this.statusDuration = const Duration(seconds: 5), // Default duration
    this.viewers = const [], // Default empty list of viewers
  }) : super(key: key);

  @override
  _StatusViewState createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late Timer _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.statusDuration,
    )..forward();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // Start a timer to auto-switch to the next status
  void _startTimer() {
    _timer = Timer.periodic(widget.statusDuration, (timer) {
      if (_currentIndex < widget.statuses.length - 1) {
        setState(() {
          _currentIndex++;
          _animationController.forward(from: 0);
        });
      } else {
        // If it's the last status, navigate back to the home screen
        Navigator.of(context).pop();
      }
    });
  }

  // Show viewers in a bottom sheet
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Display image or video
            Center(
              child: Image.asset(
                widget.statuses[_currentIndex],
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            // Gesture detection for next/previous status
            GestureDetector(
              onTapUp: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < screenWidth / 2) {
                  // Tap on left side for previous status
                  setState(() {
                    if (_currentIndex > 0) {
                      _currentIndex--;
                      _animationController.forward(from: 0);
                    }
                  });
                } else {
                  // Tap on right side for next status
                  setState(() {
                    if (_currentIndex < widget.statuses.length - 1) {
                      _currentIndex++;
                      _animationController.forward(from: 0);
                    } else {
                      Navigator.of(context).pop(); // Close if it's the last status
                    }
                  });
                }
              },
            ),
            // Close button on top-left
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
            // Progress indicator bar at the top with animation
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
                          // Light grey background bar
                          Container(
                            height: 3,
                            color: Colors.grey.shade400,
                          ),
                          // Darker progress bar that animates
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
            // Eye icon and view count at the bottom
            Positioned(
              bottom: 40,
              child: GestureDetector(
                onTap: _showViewers,
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      '${widget.viewers.length}', // Display view count
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

