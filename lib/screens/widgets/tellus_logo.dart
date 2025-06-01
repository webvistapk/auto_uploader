import 'package:flutter/material.dart';

class TellusLogo extends StatelessWidget {
  final double width;
  final double height;

  const TellusLogo({super.key, this.width = 100.0, this.height = 100.0});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/splash.png', // Ensure you have your logo in assets
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
