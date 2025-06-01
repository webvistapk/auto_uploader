import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/screens/post/view/camera/videiplayer_widget.dart';

class PreviewScreen extends StatelessWidget {
  final File file;
  const PreviewScreen({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isVideo = file.path.endsWith('.mp4');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: isVideo ? VideoPlayerWidget(file: file) : Image.file(file),
      ),
    );
  }
}
