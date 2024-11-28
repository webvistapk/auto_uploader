import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoListScreen extends StatelessWidget {
  final List<String> videoUrls = [
    'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
    'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_10mb.mp4',
    'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_30mb.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video List')),
      body: ListView.builder(
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return VideoPlayerWidget(videoUrl: videoUrls[index]);
        },
      ),
    );
  }
}

// class VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;

//   const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }

//   Future<void> _initializePlayer() async {
//     _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
//     await _videoPlayerController.initialize();
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       aspectRatio: _videoPlayerController.value.aspectRatio,
//       autoPlay: false,
//       looping: false,
//       fullScreenByDefault: false,
//     );
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: double.infinity, // Ensures the video player takes full width
//         child: _chewieController != null &&
//                 _chewieController!.videoPlayerController.value.isInitialized
//             ? AspectRatio(
//                 aspectRatio: .8,
//                 child: Chewie(controller: _chewieController!),
//               )
//             : const Center(
//                 child: CircularProgressIndicator(),
//               ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
// }

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.videoUrl);
      await _controller.initialize();
      setState(() {
        _isError = false;
      });
    } catch (e) {
      debugPrint("Video initialization error: $e");
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Center(
        child: Text("Failed to load video."),
      );
    }

    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
