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
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.9,
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

class MediaGallery extends StatefulWidget {
  final List<File> files;

  MediaGallery({Key? key, required this.files}) : super(key: key);

  @override
  _MediaGalleryState createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  Map<String, VideoPlayerController> videoControllers = {};
  int currentIndex = 0;

  bool _isVideo(File file) => file.path.toLowerCase().endsWith('.mp4');

  @override
  void initState() {
    super.initState();
    if (widget.files.isNotEmpty && _isVideo(widget.files[currentIndex])) {
      initializeVideoController(widget.files[currentIndex]);
    }
  }

  @override
  void dispose() {
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> initializeVideoController(File file) async {
    if (_isVideo(file) && !videoControllers.containsKey(file.path)) {
      final controller = VideoPlayerController.file(file);
      videoControllers[file.path] = controller;
      try {
        await controller.initialize();
        controller.setLooping(true);
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('Error initializing video: ${file.path}, Error: $e');
      }
    } else {
      if (mounted) setState(() {});
    }
  }

  void pauseCurrentVideo() {
    final currentFile = widget.files[currentIndex];
    final controller = videoControllers[currentFile.path];
    if (controller != null && controller.value.isPlaying) {
      controller.pause();
    }
  }

  void goToPrevious() async {
    if (currentIndex > 0) {
      pauseCurrentVideo();
      setState(() {
        currentIndex--;
      });
      if (_isVideo(widget.files[currentIndex])) {
        await initializeVideoController(widget.files[currentIndex]);
      } else {
        if (mounted) setState(() {});
      }
    }
  }

  void goToNext() async {
    if (currentIndex < widget.files.length - 1) {
      pauseCurrentVideo();
      setState(() {
        currentIndex++;
      });
      if (_isVideo(widget.files[currentIndex])) {
        await initializeVideoController(widget.files[currentIndex]);
      } else {
        if (mounted) setState(() {});
      }
    }
  }

  void onThumbnailTap(int index) async {
    if (index != currentIndex) {
      pauseCurrentVideo();
      setState(() {
        currentIndex = index;
      });
      if (_isVideo(widget.files[currentIndex])) {
        await initializeVideoController(widget.files[currentIndex]);
      } else {
        if (mounted) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.files.isEmpty) {
      return Center(
        child: Text(
          "No Files Selected",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final currentFile = widget.files[currentIndex];

    return Column(
      children: [
        // Preview with arrows
        Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .35,
              width: double.infinity,
              color: Colors.black,
              child: _isVideo(currentFile)
                  ? buildVideoPlayer(currentFile)
                  : buildImage(currentFile),
            ),

            // Back arrow
            if (widget.files.length > 0 && currentIndex > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 30),
                    onPressed: goToPrevious,
                  ),
                ),
              ),

            // Forward arrow
            if (widget.files.length > 0 &&
                currentIndex < widget.files.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 30),
                    onPressed: goToNext,
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: 10),

        // Media thumbnails grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(8),
            itemCount: widget.files.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final file = widget.files[index];
              bool isSelected = index == currentIndex;
              return GestureDetector(
                onTap: () => onThumbnailTap(index),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.transparent,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_isVideo(file))
                      Positioned(
                        right: 6,
                        top: 6,
                        child:
                            Icon(Icons.videocam, color: Colors.white, size: 18),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildVideoPlayer(File file) {
    final controller = videoControllers[file.path];
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
              mini: true,
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
