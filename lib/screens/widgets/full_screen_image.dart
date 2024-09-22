import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImage({super.key, required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black, // Ensure the background is tappable
          child: Center(
            child: Hero(
              tag: tag,
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
