import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class FileCarousel extends StatefulWidget {
  final List<File> files;

  FileCarousel({Key? key, required this.files}) : super(key: key);

  @override
  _FileCarouselState createState() => _FileCarouselState();
}

class _FileCarouselState extends State<FileCarousel> {
  Map<String, VideoPlayerController> videoControllers = {};

  @override
  void initState() {
    super.initState();

    // Initialize video controllers for video files
    for (var file in widget.files) {
      if (file.path.endsWith('.mp4')) {
        final controller = VideoPlayerController.file(file)
          ..initialize().then((_) {
            setState(() {
              // The controller is initialized
              debugPrint('Video initialized: ${file.path}');
            });
          }).catchError((error) {
            debugPrint('Error initializing video: ${file.path}, Error: $error');
          });
        videoControllers[file.path] = controller;
      }
    }
  }

  @override
  void dispose() {
    // Dispose video controllers
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * .35,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        enableInfiniteScroll: false,
      ),
      items: widget.files.map((file) {
        return file.path.endsWith('.mp4')
            ? buildVideoPlayer(file)
            : buildImage(file);
      }).toList(),
    );
  }

  Widget buildVideoPlayer(File file) {
    final controller = videoControllers[file.path];

    // Ensure the controller is not null and initialized
    if (controller != null && controller.value.isInitialized) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          VideoProgressIndicator(controller, allowScrubbing: true),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                });
              },
              child: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  Widget buildImage(File file) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(file),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
