import 'package:flutter/material.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/screens/messaging/widgets/media_item.dart';

class OwnMessage extends StatelessWidget {
  final String text;
  final String timestampDate;
  final String timestampTime;
  final List<dynamic> mediaList;

  const OwnMessage({
    Key? key,
    required this.text,
    required this.timestampDate,
    required this.timestampTime,
    required this.mediaList,
  }) : super(key: key);

  bool isVideo(String mediaType) {
    return mediaType == 'video';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Centered Timestamp Date
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                timestampDate,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
          // Media Gallery
          if (mediaList.isNotEmpty)
            Column(
              children: mediaList.map((media) {
                return MediaItem(
                  url: media['file'],
                  mediaType: media['media_type'],
                  timestamp: timestampTime,
                );
              }).toList(),
            ),
          // Message Bubble
          if (text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 55, top: 8.0),
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 103, 207, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
                softWrap: true,
              ),
            ),
          // Sending Time
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              timestampTime,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoThumbnail extends StatefulWidget {
  final String url;
  final String title;

  const VideoThumbnail({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  bool _isLoading = true;
  String url = "";
  @override
  Widget build(BuildContext context) {
    if (widget.url.contains(ApiURLs.baseUrl2)) {
      url = widget.url;
    } else {
      url = ApiURLs.baseUrl2 + widget.url;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Title
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            // Video Thumbnail
            Image.network(
              url,
              height: 200,
              width: MediaQuery.of(context).size.width * 0.6,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  // Loading finished
                  if (_isLoading) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  return child;
                } else {
                  // Still loading
                  return Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width * 0.6,
                    color: Colors.grey.shade300,
                  );
                }
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                width: MediaQuery.of(context).size.width * 0.6,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.red,
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
            // Loading Indicator
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ],
    );
  }
}
