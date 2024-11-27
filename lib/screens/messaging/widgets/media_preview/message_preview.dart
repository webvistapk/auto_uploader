import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/screens/messaging/widgets/media_preview/video_player_file.dart';
// import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatelessWidget {
  final List<File> mediaFiles;

  const MediaPreviewScreen({Key? key, required this.mediaFiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Preview')),
      body: ListView.builder(
        itemCount: mediaFiles.length,
        itemBuilder: (context, index) {
          final file = mediaFiles[index];
          if (file.path.endsWith('.mp4') || file.path.endsWith('.avi')) {
            return VideoPlayerFile(file: file);
          } else {
            return Image.file(file);
          }
        },
      ),
    );
  }
}
