import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class postFullScreen extends StatelessWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const postFullScreen({
    Key? key,
    required this.mediaUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: CarouselSlider.builder(
          itemCount: mediaUrls.length,
          itemBuilder: (context, index, realIndex) {
            return Image.network(
              mediaUrls[index],
              fit: BoxFit.contain,
              width: double.infinity,
            );
          },
          options: CarouselOptions(
            initialPage: initialIndex,
            enableInfiniteScroll: false,
            viewportFraction: 1.0,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
