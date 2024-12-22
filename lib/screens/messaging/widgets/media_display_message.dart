import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaMessageDisplay extends StatefulWidget {
  final String mediaUrl;

  const MediaMessageDisplay({Key? key, required this.mediaUrl})
      : super(key: key);

  @override
  _MediaMessageDisplayState createState() => _MediaMessageDisplayState();
}

class _MediaMessageDisplayState extends State<MediaMessageDisplay> {
  late VideoPlayerController? _videoController;
  late bool _isVideo;

  @override
  void initState() {
    super.initState();
    _determineMediaType();
  }

  /// Determines the media type based on the URL extension
  void _determineMediaType() {
    final url = widget.mediaUrl.toLowerCase();

    if (_isVideoUrl(url)) {
      _isVideo = true;
      _initializeVideoPlayer();
    } else if (_isImageUrl(url)) {
      _isVideo = false;
    } else {
      _isVideo = false;
      _showUnsupportedFormatDialog();
    }
  }

  /// Checks if the URL points to a video
  bool _isVideoUrl(String url) {
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
  }

  /// Checks if the URL points to an image
  bool _isImageUrl(String url) {
    return url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.endsWith('.gif');
  }

  /// Initializes the video player
  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.network(widget.mediaUrl)
      ..initialize().then((_) {
        setState(() {});
        _videoController?.play();
      }).catchError((error) {
        _showInitializationErrorDialog(error.toString());
      });
  }

  /// Displays a dialog for unsupported formats
  void _showUnsupportedFormatDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsupported Format'),
          content: const Text(
              'The provided URL does not point to a supported media format.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  /// Displays an error dialog if video initialization fails
  void _showInitializationErrorDialog(String errorMessage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to initialize video: $errorMessage'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: _isVideo
            ? _buildVideoPlayer()
            : _isImageUrl(widget.mediaUrl)
                ? _buildImage()
                : const Text(
                    'Unsupported media format',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
      ),
    );
  }

  /// Builds the video player widget
  Widget _buildVideoPlayer() {
    return _videoController != null && _videoController!.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          )
        : const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
  }

  /// Builds the image widget
  Widget _buildImage() {
    return Image.network(
      widget.mediaUrl,
      fit: BoxFit.contain,
      width: MediaQuery.of(context).size.width,
      errorBuilder: (context, error, stackTrace) {
        return const Text(
          'Failed to load image',
          style: TextStyle(color: Colors.red),
        );
      },
    );
  }
}
