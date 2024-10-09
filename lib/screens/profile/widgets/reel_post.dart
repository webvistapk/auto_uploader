import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ReelPost extends StatefulWidget {

  final String? src;
  const ReelPost({Key? key,required this.src}) : super(key: key);

  @override
  _ReelPostState createState() => _ReelPostState();
}

class _ReelPostState extends State<ReelPost> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
    //print("this URL ${widget.src}");
  }

  Future<void> initializePlayer() async {
    if (widget.src == null) {
      print('Video source is null');
      return; // Handle this case accordingly
    }

    print("Initializing video player with URL: ${widget.src}");

    try {
      _videoPlayerController = VideoPlayerController.network(widget.src!);
      await _videoPlayerController.initialize();
      print("Initialized Successfully");
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        showControls: false,
        looping: true,
      );

      setState(() {});
    } catch (e) {
      print('Error initializing video player: $e');
      // Handle the error as necessary
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
            ? GestureDetector(
          onDoubleTap: () {
            setState(() {

            });
          },
          child: Chewie(
            controller: _chewieController!,
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading...'),


          ],
        ),

      ],
    );
  }
}
