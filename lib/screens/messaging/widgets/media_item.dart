import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/screens/messaging/widgets/message_video_player.dart';

class MediaItem extends StatefulWidget {
  final String url;
  final String mediaType;
  final String timestamp;

  const MediaItem({
    Key? key,
    required this.url,
    required this.mediaType,
    required this.timestamp,
  }) : super(key: key);

  @override
  State<MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.mediaType == 'video'
                ? MessageVideoPlayer(videoUrl: widget.url)
                : _buildImage(widget.url, size),
          ),
          // Timestamp on Bottom-Right
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.timestamp,
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url, Size size) {
    if (!url.contains(ApiURLs.baseUrl2)) {
      url = ApiURLs.baseUrl2 + url;
      if (mounted) setState(() {});
    }
    return Image.network(
      url,
      height: 200,
      width: size.width * .60,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          width: size.width * .60,
          color: Colors.grey.shade300,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: 200,
        width: size.width * .60,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(String url) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Video Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            color: Colors.grey.shade300,
            child: Center(
              child: Text(
                'Video Thumbnail\nNot Loaded',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        ),
        // Play Icon
        const Icon(
          Icons.play_circle_fill,
          size: 50,
          color: Colors.white,
        ),
        // Show timestamp at the bottom right
      ],
    );
  }
}
