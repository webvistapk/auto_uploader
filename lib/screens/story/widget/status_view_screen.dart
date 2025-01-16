// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile/controller/endpoints.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';

// import '../../../controller/services/StatusProvider.dart';
// import '../../../models/UserProfile/userprofile.dart';
// import '../create_story_screen.dart';

// class StatusView extends StatefulWidget {
//   final List<Object?> statuses;
//   final int initialIndex;
//   final bool isVideo;
//   final Duration statusDuration;
//   final List<String> viewers;
//   final UserProfile? userProfile;
//   final String token;
//   final bool isUser;
//   final List<int?>? statusId;

//   StatusView({
//     Key? key,
//     required this.statuses,
//     required this.initialIndex,
//     required this.isVideo,
//     this.statusDuration = const Duration(seconds: 5),
//     this.viewers = const [],
//     required this.userProfile,
//     required this.token,
//     required this.isUser,
//     this.statusId,
//   }) : super(key: key);

//   @override
//   _StatusViewState createState() => _StatusViewState();
// }

// class _StatusViewState extends State<StatusView> with TickerProviderStateMixin {
//   int _currentIndex = 0;
//   int _offset = 0; // Tracks the current offset for pagination
//   final int _limit = 10; // Limit per fetch
//   Timer? _timer;
//   late AnimationController _animationController;
//   VideoPlayerController? _videoController;
//   bool _isLoading = true;
//   bool _hasMore = true; // Flag to check if more statuses need to be loaded

//   @override
//   void initState() {
//     super.initState();

//     context.read<MediaProvider>();
//     _currentIndex = widget.initialIndex;
//     _animationController =
//         AnimationController(vsync: this, duration: Duration(seconds: 15));
//     _initializeStatus();
//     _loadStatuses(); // Initial status fetch
//   }

//   // Method to load statuses with pagination
//   void _loadStatuses() {
//     final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
//     mediaProvider.fetchUserStatuses(limit: _limit, offset: _offset).then((_) {
//       if (mounted)
//         setState(() {
//           _isLoading = false;
//           _hasMore = mediaProvider.hasMore;
//         });
//     });
//   }

//   void _onDeleteStory() {
//     // Pause the animation and timer when the dialog is opened
//     _animationController.stop();
//     _timer?.cancel();
//     _videoController?.pause();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Delete Story"),
//         content: Text("Are you sure you want to delete this story?"),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               // Resume animation and timer after closing the dialog
//               _resumeStatus();
//             },
//             child: Text("No"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               context
//                   .read<MediaProvider>()
//                   .deleteUserStories(widget.statusId![_currentIndex]!, context)
//                   .then((_) {
//                 setState(() {
//                   // Reset or initialize the status view
//                   _initializeStatus();
//                 });
//               });
//             },
//             child: Text("Yes"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _resumeStatus() {
//     if (widget.isVideo && _videoController != null) {
//       _videoController!.play();
//     }
//     final remainingTime =
//         _animationController.duration! * (1.0 - _animationController.value);
//     _animationController.forward();
//     _timer = Timer(remainingTime, _onNextStatus);
//   }

//   void _initializeStatus() {
//     _animationController.stop();
//     _timer?.cancel();
//     if (mounted) setState(() => _isLoading = true);

//     if (widget.isVideo) {
//       _initializeVideo();
//     } else {
//       _initializeImage();
//     }
//   }

//   Future<void> _initializeVideo() async {
//     _videoController = VideoPlayerController.network(
//         '${ApiURLs.baseUrl2}${widget.statuses[_currentIndex]}');

//     _videoController!.addListener(() {
//       if (_videoController!.value.isBuffering) {
//         if (mounted)
//           setState(() {
//             _isLoading = true;
//           });
//       } else if (_videoController!.value.isInitialized) {
//         if (mounted)
//           setState(() {
//             _isLoading = false;
//           });
//       }
//     });

//     try {
//       await _videoController!.initialize();
//       final videoDuration = _videoController!.value.duration;
//       final cappedDuration = videoDuration <= Duration(seconds: 10)
//           ? videoDuration
//           : Duration(seconds: 10);

//       _animationController.duration = cappedDuration;
//       _videoController!.play();
//       _animationController.forward(from: 0);
//       _timer = Timer(cappedDuration, _onNextStatus);
//     } catch (e) {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _initializeImage() {
//     _animationController.stop();
//     _timer?.cancel();
//     if (mounted) setState(() => _isLoading = true);

//     Image.network(
//       '${ApiURLs.baseUrl2}${widget.statuses[_currentIndex]}',
//       fit: BoxFit.cover,
//     ).image.resolve(ImageConfiguration()).addListener(
//           ImageStreamListener(
//             (ImageInfo info, bool _) {
//               if (mounted)
//                 setState(() {
//                   _isLoading = false;
//                   _animationController.duration = Duration(seconds: 10);
//                   _animationController.forward(from: 0);
//                 });
//               _timer = Timer(Duration(seconds: 10), _onNextStatus);
//             },
//             onError: (error, stackTrace) {
//               if (mounted) setState(() => _isLoading = false);
//             },
//           ),
//         );
//   }

//   void _onNextStatus() {
//     _animationController.stop();
//     _timer?.cancel();

//     if (_currentIndex < widget.statuses.length - 1) {
//       if (mounted)
//         setState(() {
//           _currentIndex++;
//         });
//       _initializeStatus();
//     } else if (_hasMore) {
//       // Load next batch of statuses when the current batch ends
//       if (mounted)
//         setState(() {
//           _offset += _limit;
//           _isLoading = true;
//         });
//       _loadStatuses(); // Fetch next batch
//     } else {
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _animationController.dispose();
//     _videoController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Builder(builder: (context) {
//         var pro = context.watch<MediaProvider>();
//         return Stack(
//           alignment: Alignment.center,
//           clipBehavior: Clip.none,
//           children: [
//             Center(
//               child: _isLoading
//                   ? CircularProgressIndicator()
//                   : widget.isVideo &&
//                           _videoController != null &&
//                           _videoController!.value.isInitialized
//                       ? AspectRatio(
//                           aspectRatio: _videoController!.value.aspectRatio,
//                           child: VideoPlayer(_videoController!),
//                         )
//                       : Image.network(
//                           '${ApiURLs.baseUrl2}${widget.statuses[_currentIndex]}',
//                           fit: BoxFit.contain,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Icon(Icons.error, color: Colors.white),
//                           height: MediaQuery.of(context).size.height,
//                           width: MediaQuery.of(context).size.width,
//                         ),
//             ),
//             GestureDetector(
//               onTapUp: (details) {
//                 final screenWidth = MediaQuery.of(context).size.width;
//                 if (details.globalPosition.dx < screenWidth / 2) {
//                   if (_currentIndex > 0) _onPreviousStatus();
//                 } else {
//                   if (_currentIndex < widget.statuses.length - 1) {
//                     _onNextStatus();
//                   } else {
//                     Navigator.of(context).pop();
//                   }
//                 }
//               },
//               onLongPressStart: (_) {
//                 _animationController.stop();
//                 _timer?.cancel();
//                 _videoController?.pause();
//               },
//               onLongPressEnd: (_) {
//                 _animationController.forward();
//                 _timer = Timer(
//                     _animationController.duration! *
//                         (1.0 - _animationController.value),
//                     _onNextStatus);
//                 _videoController?.play();
//               },
//             ),
//             Positioned(
//               top: 40,
//               left: 20,
//               child: IconButton(
//                 icon: Icon(Icons.close, color: Colors.white, size: 30),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ),
//             Positioned(
//               top: 10,
//               left: 10,
//               right: 10,
//               child: Row(
//                 children: List.generate(
//                   widget.statuses.length,
//                   (index) => Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 2),
//                       child: Stack(
//                         children: [
//                           Container(
//                             height: 3,
//                             color: Colors.grey.shade400,
//                           ),
//                           index == _currentIndex
//                               ? AnimatedBuilder(
//                                   animation: _animationController,
//                                   builder: (context, child) {
//                                     return Container(
//                                       height: 3,
//                                       width: MediaQuery.of(context).size.width *
//                                           _animationController.value,
//                                       color: Colors.white,
//                                     );
//                                   },
//                                 )
//                               : Container(
//                                   height: 3,
//                                   color: index < _currentIndex
//                                       ? Colors.white
//                                       : Colors.transparent,
//                                 ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             widget.isUser
//                 ? Positioned(
//                     bottom: 40,
//                     child: GestureDetector(
//                       onTap: _showViewers,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           GestureDetector(
//                               onTap: _onDeleteStory,
//                               child: Icon(
//                                 Icons.delete,
//                                 size: 27,
//                                 color: Colors.white,
//                               )),
//                           SizedBox(width: 15),
//                           Icon(Icons.remove_red_eye, color: Colors.white),
//                           SizedBox(width: 5),
//                           Text(
//                             '${widget.viewers.length}',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                           SizedBox(width: 10),
//                           GestureDetector(
//                               onTap: () {
//                                 Navigator.of(context).pop();
//                                 Navigator.push(
//                                     context,
//                                     CupertinoDialogRoute(
//                                         builder: (_) => StoryScreen(
//                                               userProfile: widget.userProfile,
//                                               token: widget.token,
//                                             ),
//                                         context: context));
//                               },
//                               child: Icon(
//                                 Icons.add_circle_outline,
//                                 size: 27,
//                                 color: Colors.white,
//                               )),
//                         ],
//                       ),
//                     ),
//                   )
//                 : Container(),
//           ],
//         );
//       }),
//     );
//   }

//   void _onPreviousStatus() {
//     if (_currentIndex > 0) {
//       if (mounted)
//         setState(() {
//           _currentIndex--;
//         });
//       _initializeStatus();
//     }
//   }

//   void _showViewers() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: EdgeInsets.all(16),
//           height: 300,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Viewers',
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontFamily: 'Greycliff CF',
//                     fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: widget.viewers.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       leading: Icon(Icons.person),
//                       title: Text(widget.viewers[index]),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

import '../../../controller/endpoints.dart';
import '../../../controller/services/StatusProvider.dart';
import '../../../models/UserProfile/userprofile.dart';
import '../create_story_screen.dart';

class StatusView extends StatefulWidget {
  final List<Object?> statuses;
  final int initialIndex;
  final List<String> viewers;
  final UserProfile? userProfile;
  final String token;
  final bool isUser;
  final List<int?>? statusId;

  StatusView({
    Key? key,
    required this.statuses,
    required this.initialIndex,
    this.viewers = const [],
    required this.userProfile,
    required this.token,
    required this.isUser,
    this.statusId,
  }) : super(key: key);

  @override
  _StatusViewState createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  final StoryController _storyController = StoryController();
  int _offset = 0;
  final int _limit = 10;
  bool _isLoading = true;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  void _loadStatuses() {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    mediaProvider.fetchUserStatuses(limit: _limit, offset: _offset).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMore = mediaProvider.hasMore;
        });
      }
    });
  }

  void _onDeleteStory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Story"),
        content: Text("Are you sure you want to delete this story?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<MediaProvider>()
                  .deleteUserStories(
                      widget.statusId![widget.initialIndex]!, context)
                  .then((_) {
                setState(() => _loadStatuses());
              });
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : StoryView(
              controller: _storyController,
              storyItems: widget.statuses.map((status) {
                if (status is String && status.contains('.mp4')) {
                  return StoryItem.pageVideo(
                    '${ApiURLs.baseUrl2}$status',
                    controller: _storyController,
                    caption: Text(
                      'Video Story',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return StoryItem.pageImage(
                    url: '${ApiURLs.baseUrl2}$status',
                    controller: _storyController,
                    caption: Text(
                      'Image Story',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
              }).toList(),
              onComplete: () {
                if (_hasMore) {
                  setState(() {
                    _offset += _limit;
                    _isLoading = true;
                  });
                  _loadStatuses();
                } else {
                  Navigator.of(context).pop();
                }
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.of(context).pop();
                }
              },
            ),
      floatingActionButton: widget.isUser
          ? FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: _onDeleteStory,
              child: Icon(Icons.delete),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }
}
