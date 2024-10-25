import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
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
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeVideoController(widget.files[currentIndex]);
  }

  @override
  void dispose() {
    // Dispose video controllers
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void initializeVideoController(File file) {
    if (file.path.endsWith('.mp4') &&
        !videoControllers.containsKey(file.path)) {
      final controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {
            // Video is ready to play
          });
        }).catchError((error) {
          debugPrint('Error initializing video: ${file.path}, Error: $error');
        });
      videoControllers[file.path] = controller;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.files.isEmpty
        ? Text(
            "No Files Selected",
            style: AppTextStyles.poppinsBold(color: Colors.white),
          )
        : CarouselSlider.builder(
            itemCount: widget.files.length,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * .35,
              autoPlay: false,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  // Pause the current video if it's playing
                  if (videoControllers[widget.files[currentIndex].path]
                          ?.value
                          .isPlaying ??
                      false) {
                    videoControllers[widget.files[currentIndex].path]?.pause();
                  }
                  currentIndex = index;

                  // Initialize the new video's controller if needed
                  initializeVideoController(widget.files[currentIndex]);
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final file = widget.files[index];
              return file.path.endsWith('.mp4')
                  ? buildVideoPlayer(file)
                  : buildImage(file);
            },
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
