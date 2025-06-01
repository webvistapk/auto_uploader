import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;

  const AppLogo({super.key, this.width = 100.0, this.height = 100.0});

  @override
  Widget build(BuildContext context) {
    return height != null && width != null
        ? Image.asset(
            'assets/splash.png', // Ensure you have your logo in assets
            width: width,
            height: height,
          )
        : Image.asset(
            'assets/splash.png', // Ensure you have your logo in assets
          );
  }
}
