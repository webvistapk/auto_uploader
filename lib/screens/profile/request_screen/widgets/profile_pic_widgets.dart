import 'package:flutter/material.dart';

class AnimatedProfilePicture extends StatefulWidget {
  final String profileImageUrl;
  final double size;

  const AnimatedProfilePicture({
    Key? key,
    required this.profileImageUrl,
    this.size = 100.0, // Default size if not provided
  }) : super(key: key);

  @override
  _AnimatedProfilePictureState createState() => _AnimatedProfilePictureState();
}

class _AnimatedProfilePictureState extends State<AnimatedProfilePicture>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the animation (scale effect)
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Start the animation when the widget is built
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: ClipOval(
          child: Image.network(
            widget.profileImageUrl,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.error,
              size: widget.size,
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
